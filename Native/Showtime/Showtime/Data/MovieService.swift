/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import JavaScriptCore

let movieUrl = "https://itunes.apple.com/us/rss/topmovies/limit=50/json"

class MovieService {
  
    //PROPERTIES

        lazy var context: JSContext? = {
                
            let context = JSContext()
                
            guard let
                commonJSPath = NSBundle.mainBundle().pathForResource("common", ofType: "js"),
                additionsJSPath = NSBundle.mainBundle().pathForResource("additions", ofType: "js") else {
                print("Unable to read resource files.")
                return nil
            }
                
            do {
                let common = try String(contentsOfFile: commonJSPath, encoding: NSUTF8StringEncoding)
                let additions = try String(contentsOfFile: additionsJSPath, encoding: NSUTF8StringEncoding)
                    
                context.setObject(Movie.self, forKeyedSubscript: "Movie")
                context.evaluateScript(common)
                context.evaluateScript(additions)
            } catch (let error) {
                print("Error while processing script file: \(error)")
            }
                
            return context
        }()
            
    //METHODS
    
    //Fetches the movies using the default shared NSURLSession.
    //Before passing response to JS code, need to provide an execution context for the response.
    
    func loadMoviesWithLimit(limit: Double, onComplete complete: [Movie] -> ()) {
        guard let url = NSURL(string: movieUrl) else {
            print("Invalid url format: \(movieUrl)")
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { data, _, _ in
            guard let data = data,
                jsonString = String(data: data, encoding: NSUTF8StringEncoding) else {
                    print("Error while parsing the response data.")
                    return
            }
            
            let movies = self.parseResponse(jsonString, withLimit:limit)
            complete(movies)
            
            }.resume()
    }
    
    func parseResponse(response: String, withLimit limit: Double) -> [Movie] {
        guard let context = context else {
            print("JSContext not found.")
            return []
        }
        
        let parseFunction = context.objectForKeyedSubscript("parseJson")
        let parsed = parseFunction.callWithArguments([response]).toArray()
        
        let filterFunction = context.objectForKeyedSubscript("filterByLimit")
        let filtered = filterFunction.callWithArguments([parsed, limit]).toArray()
        
        let mapFunction = context.objectForKeyedSubscript("mapToNative")
        guard let unwrappedFiltered = filtered,
            movies = mapFunction.callWithArguments([unwrappedFiltered]).toArray() as? [Movie] else {
                return []
        }
        
        return movies
    }
}








