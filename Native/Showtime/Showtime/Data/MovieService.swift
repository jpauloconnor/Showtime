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
    
    //1 Load common.js file from the application bundle
    //2 After loading the file, the context object evaluates contents by calling context.evauluateScript(), passing the file contents for the parameter.
    lazy var context: JSContext? = {
        let context = JSContext()
        
        // 1
        guard let
            commonJSPath = NSBundle.mainBundle().pathForResource("common", ofType: "js") else {
                print("Unable to read resource files.")
                return nil
        }
        
        // 2
        do {
            let common = try String(contentsOfFile: commonJSPath, encoding: NSUTF8StringEncoding)
            context.evaluateScript(common)
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

    
    //Reaches out to shared JS code to process API response
        
    func parseResponse(response: String, withLimit limit: Double) -> [Movie] {
        // 1
        guard let context = context else {
            print("JSContext not found.")
            return []
        }
        
        // 2
        let parseFunction = context.objectForKeyedSubscript("parseJson")
        let parsed = parseFunction.callWithArguments([response]).toArray()
        
        // 3
        let filterFunction = context.objectForKeyedSubscript("filterByLimit")
        let filtered = filterFunction.callWithArguments([parsed, limit]).toArray()
        
        // 4
        return []
    }
}
