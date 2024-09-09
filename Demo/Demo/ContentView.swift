//
//  ContentView.swift
//  Demo
//
//  Created by George Kyrylenko on 09.09.2024.
//

import SwiftUI
import GKLogger
import MessageUI

struct ContentView: View {
    @State var logsUrl: URL?
    @State var shareDialog = false
    @State var shareEmail = false
    @State var logLevel = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        List {
            Section("Log Level") {
                Picker("What is your favorite color?", selection: $logLevel) {
                    Text("Debug").tag(0)
                    Text("Info").tag(1)
                    Text("Warning").tag(2)
                    Text("Error").tag(3)
                    Text("None").tag(4)
                        }
                        .pickerStyle(.segmented)
            }
            .onChange(of: logLevel) { oldValue, newValue in
                GKLogger.logLevel = LogLevel(rawValue: logLevel) ?? .debug
            }
            Section("Print Logs") {
                Button("Debug Log") {
                    GKLogger.log("Debug", type: .debug)
                }
                
                Button("Info Log") {
                    GKLogger.log("Info", type: .info)
                }
                
                Button("Warning Log") {
                    GKLogger.log("Warning", type: .warning)
                }
                
                Button("Error Log") {
                    GKLogger.log("Error", type: .error)
                }
                
                Button("None Log") {
                    GKLogger.log("None", type: .none)
                }
            }
            Section("Share Logs") {
                Button("Share via email") {
                    shareEmail = true
                }
                .sheet(isPresented: $shareEmail) {
                    MailView(result: $result,
                             email: "test@test.test",
                             subject: "Logs",
                             body: "Logs")
                }
                
                Button("Share by menu") {
                    GKLogger.logsURL { url in
                        DispatchQueue.main.async {
                            if let url {
                                logsUrl = url
                                shareDialog = true
                            } else {
                                
                            }
                        }
                    }
                }
                .sheet(isPresented: $shareDialog) {
                    ShareView(url: $logsUrl)
                }
            }
        }
        .onAppear {
            GKLogger.logsLimit = 5000
        }
    }
}

#Preview {
    ContentView()
}


struct ShareView: UIViewControllerRepresentable {
    @Binding var url: URL?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        if let url {
            return UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        return UIActivityViewController(activityItems: [], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareView>) {}
}
