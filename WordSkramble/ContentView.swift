//
//  ContentView.swift
//  WordSkramble
//
//  Created by Юрий Филатов on 21.07.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMasage = ""
    @State private var shouingError = false
    @State private var playerScore = 0
    
    var body: some View {
        NavigationView{
            VStack{
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/).ignoresSafeArea(.all)
                TextField("Enter you word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("You score is : \(playerScore)")
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $shouingError) {
                Alert(title: Text(errorTitle), message: Text(errorMasage), dismissButton: .default(Text("OK")))
                }
            
            .toolbar(){
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Restart", action:{
                        startGame()
                        playerScore = 0
                        
                    })
                    .listItemTint(.white)
                }
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal (word: answer) else {
            wordError(title: "Word used already", masage: "Be more original")
            return
        }
        
        guard isPosible(word: answer) else {
            wordError(title: "Word not recognized", masage: "You can't just make them up, you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not posile", masage: "This isn't a real word!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        playerScore += answer.count
    }
    
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundel.")
    }
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPosible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
            
        }
        
        return true
    }
    
    
    func isReal (word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError (title: String, masage: String) {
        errorTitle = title
        errorMasage = masage
        shouingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
