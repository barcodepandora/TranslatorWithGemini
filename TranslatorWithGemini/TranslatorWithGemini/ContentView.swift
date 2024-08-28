//
//  ContentView.swift
//  TranslatorWithGemini
//
//  Created by Juan Manuel Moreno on 28/08/24.
//

import SwiftUI
import GoogleGenerativeAI
import PDFKit

//let apikey = "AIzaSyDKGv5FdPX3ocAPrSrOYAriC1ZGBa_Gox0"
let apikey = "AIzaSyBME3QqYa7rMIMWQKsNW1iTjj6jN0YBB18"

struct TextPart: ThrowingPartsRepresentable {
    let text: String

    func tryPartsValue() throws -> [GoogleGenerativeAI.ModelContent.Part] {
        return [.text(text)]
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button(action: {
                Task {
                    do {
                        let translations = try await translatePDFByPage(fileName: "ProjectA", targetLanguage: "spanish")
                        for (index, translation) in translations.enumerated() {
                            print("Traducción de la página \(index + 1):\n\(translation)\n")
                        }
                    } catch {
                        print("Error durante la traducción: \(error)")
                    }
                }
            }) {
                Text("Traduceme")
            }
        }
        .padding()
    }
        
    func createPDFDocumentFromProject(fileName: String) -> PDFDocument? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") else {
            print("Error: Could not find file \(fileName).pdf in the project bundle.")
            return nil
        }

        return PDFDocument(url: url)
    }
    
    func translatePDFByPage(fileName: String, targetLanguage: String) async throws -> [String] {
        guard let pdfDocument = createPDFDocumentFromProject(fileName: fileName) else {
            throw NSError(domain: "PDFTranslationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error al cargar el PDF"])
        }

        var translatedPages: [String] = []
        
        let model = GoogleGenerativeAI.GenerativeModel(name: "gemini-pro", apiKey: apikey, generationConfig: GenerationConfig(maxOutputTokens: 2048))

        for pageIndex in 15...16 {
            guard let page = pdfDocument.page(at: pageIndex) else {
                throw NSError(domain: "PDFTranslationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error al acceder a la página \(pageIndex)"])
            }
            let pageText = page.string ?? ""

//            let prompt = "Traduce el siguiente texto al \(targetLanguage):\n\n\(pageText)"
            let prompt = "Translate the following text to \(targetLanguage):\n\n\(pageText)"
            let textPart = TextPart(text: prompt)
            let response = try await model.generateContent([textPart])
            
            translatedPages.append(response.text!)
        }

        return translatedPages
    }
}

#Preview {
    ContentView()
}
