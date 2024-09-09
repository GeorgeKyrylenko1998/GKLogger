//
//  StringHelper.swift
//  
//
//  Created by George Kyrylenko on 09.09.2024.
//

import Foundation

extension String {
    public func writeStringToFile(fileName: String) -> URL? {
        do {
            // Get the app's documents directory
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                 in: .userDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: true)
            
            // Create the file URL
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // Convert the string to data
            if let data = self.data(using: .utf8) {
                // Write the data to the file
                try data.write(to: fileURL)
                
                print("Successfully wrote string to file: \(fileURL.path)")
                
                return fileURL
            }
        } catch {
            print("Error writing string to file: \(error)")
        }
        
        return nil
    }
    
}
