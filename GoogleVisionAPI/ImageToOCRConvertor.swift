//
//  ImageToOCRConvertor.swift
//  GoogleVision
//
//  Created by sculpsoft-mac on 09/01/19.
//  Copyright © 2019 IND. All rights reserved.
//

import UIKit



class ImageToOCRConvertor{
    func convert(with image: UIImage,completionHanlder:@escaping (_ error:Error?,_ convertedString:String?)->()) {
        
        let imageBase64 = self.base64EncodeImage(image)
        
        var googleAPIKey = "YOUR_API_KEY"
        var googleURL: URL {
            return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
        }
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
        URLSession.shared.dataTask(with: request) { (data, res, err) in
            if let error = err{
                completionHanlder(error,nil)
            }else if let dataResp = data{
                if let json = try? JSONSerialization.jsonObject(with: dataResp, options: .mutableContainers),let object = json as? [String:Any]{
                    print(String(data: dataResp, encoding: .utf8)!)
                    completionHanlder(nil,"")
                }
            }else{
                completionHanlder(nil,nil)
            }
            }.resume()
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        if var imagedata = image.pngData(){
            if (imagedata.count > 2097152) {
                let oldSize: CGSize = image.size
                let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
                imagedata = resizeImage(newSize, image: image)
            }
            return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
        }
        
        return ""
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
