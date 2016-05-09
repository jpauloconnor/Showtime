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

import Foundation
import JavaScriptCore

//Specify all the properties to export/define a class method to construct Movie objects in JS. 
@objc protocol MovieJSExports: JSExport {
    var title: String { get set }
    var price: String { get set }
    var imageUrl: String { get set }
    
    static func movieWithTitle(title: String, price: String, imageUrl: String) -> Movie
}


class Movie: NSObject {
  
  var title: String
  var price: String
  var imageUrl: String
  
  init(title: String, price: String, imageUrl: String) {
    self.title = title
    self.price = price
    self.imageUrl = imageUrl
  }
    
    //METHODS:
    
    //Closure that takes an array of JS objects(dictionaries) uses them to construct movie instances.
    static let movieBuilder: @convention(block) [[String : String]] -> [Movie] = { object in
        return object.map { dict in
            
            guard let
                title = dict["title"],
                price = dict["price"],
                imageUrl = dict["imageUrl"] else {
                    print("unable to parse Movie objects.")
                    fatalError()
            }
            
            return Movie(title: title, price: price, imageUrl: imageUrl)
        }
    }
    
}