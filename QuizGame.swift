import Foundation

// Structure de données pour représenter une question
struct Question {
    let text: String
    let choices: [String]
    let correctAnswerIndex: Int
    let difficulty: Int // Niveau de difficulté de la question
}

// Fonction pour afficher une question et ses choix
func displayQuestion(_ question: Question) {
    print(question.text)
    for (index, choice) in question.choices.enumerated() {
        print("\(index + 1). \(choice)")
    }
}

// Fonction pour obtenir la réponse de l'utilisateur
func getUserAnswer() -> Int? {
    print("Votre réponse (entrez le numéro) : ", terminator: "")
    guard let input = readLine(), let answer = Int(input) else {
        print("Réponse invalide.")
        return nil
    }
    return answer
}

// Fonction pour vérifier la réponse et afficher le résultat
func checkAnswer(_ answer: Int, forQuestion question: Question, startTime: DispatchTime) -> Bool {
    let correctAnswerIndex = question.correctAnswerIndex
    let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
    let elapsedSeconds = Double(elapsedTime) / 1_000_000_000
    
    if answer == correctAnswerIndex + 1 {
        print("Bonne réponse !")
        if elapsedSeconds < 5 {
            print("Vous avez répondu en moins de 5 secondes ! Bonus d'un point !")
            return true
        }
        return true
    } else {
        print("Mauvaise réponse. La bonne réponse était : \(question.choices[correctAnswerIndex])")
        return false
    }
}

// Fonction principale du jeu
func runQuiz(questions: [Question], playerName: String, difficulty: Int) {
    var score = 0
    
    print("Bienvenue dans le Quiz !")
    print("Niveau de difficulté sélectionné : \(difficulty)")
    
    // Filtrer les questions en fonction du niveau de difficulté sélectionné
    let filteredQuestions = questions.filter { $0.difficulty <= difficulty }
    
    // Mélanger les questions pour les présenter dans un ordre aléatoire
    let shuffledQuestions = filteredQuestions.shuffled()
    
    // Itérer à travers les questions mélangées
    for (index, question) in shuffledQuestions.enumerated() {
        print("\nQuestion \(index + 1)/\(shuffledQuestions.count):")
        displayQuestion(question)
        
        let group = DispatchGroup()
        group.enter()
        var userAnswer: Int?
        DispatchQueue.global().async {
            userAnswer = getUserAnswer()
            group.leave()
        }
        
        let startTime = DispatchTime.now()
        let result = group.wait(timeout: .now() + 30) // Attendre 30 secondes
        if result == .timedOut {
            print("Temps écoulé. La question sera marquée comme incorrecte.")
        } else {
            if let answer = userAnswer, checkAnswer(answer, forQuestion: question, startTime: startTime) {
                score += 1
            }
        }
    }
    
    print("\nFin du quiz !")
    print("Score final pour \(playerName) : \(score)/\(shuffledQuestions.count)")
}

// Exemple de données de quiz
var quizQuestions = [
    Question(text: "Quel est le symbole chimique de l'eau ?", choices: ["O", "H2O", "H", "O2"], correctAnswerIndex: 1, difficulty: 1),
    Question(text: "Combien de continents y a-t-il sur Terre ?", choices: ["4", "5", "6", "7"], correctAnswerIndex: 3, difficulty: 1),
    Question(text: "Qui a écrit 'Roméo et Juliette' ?", choices: ["William Shakespeare", "Charles Dickens", "Jane Austen", "F. Scott Fitzgerald"], correctAnswerIndex: 0, difficulty: 1),
    Question(text: "Quelle est la capitale de la France ?", choices: ["Paris", "Londres", "Berlin", "Rome"], correctAnswerIndex: 0, difficulty: 1),
    Question(text: "Quel est l'organe principal du système respiratoire chez les humains ?", choices: ["Poumon", "Coeur", "Estomac", "Foie"], correctAnswerIndex: 0, difficulty: 2),
    Question(text: "Qui a peint 'La Joconde' ?", choices: ["Leonardo da Vinci", "Vincent van Gogh", "Pablo Picasso", "Michelangelo"], correctAnswerIndex: 0, difficulty: 2),
    Question(text: "Quel est le noyau de l'atome ?", choices: ["Electron", "Proton", "Neutron", "Positron"], correctAnswerIndex: 2, difficulty: 2),
    Question(text: "Qui a inventé l'ampoule électrique ?", choices: ["Thomas Edison", "Alexander Graham Bell", "Nikola Tesla", "Albert Einstein"], correctAnswerIndex: 0, difficulty: 2),
    Question(text: "Qui a écrit 'Le Petit Prince' ?", choices: ["Antoine de Saint-Exupéry", "Jules Verne", "Marcel Proust", "Victor Hugo"], correctAnswerIndex: 0, difficulty: 3),
    Question(text: "Quelle est la formule chimique du dioxyde de carbone ?", choices: ["CO", "CO2", "C2H6O", "O2"], correctAnswerIndex: 1, difficulty: 3)
]

// Fonction pour démarrer le jeu
func startGame() {
    print("Entrez votre nom : ", terminator: "")
    guard let playerName = readLine(), !playerName.isEmpty else {
        print("Nom invalide.")
        return
    }
    
    print("Sélectionnez un niveau de difficulté (1-3) : ", terminator: "")
    guard let input = readLine(), let difficulty = Int(input), (1...3).contains(difficulty) else {
        print("Niveau de difficulté invalide.")
        return
    }

    // Démarrer le quiz avec le nom du joueur et le niveau de difficulté sélectionné
    runQuiz(questions: quizQuestions, playerName: playerName, difficulty: difficulty)
}

// Fonction pour ajouter une nouvelle question au quiz
func addQuestion() {
    print("Entrez le texte de la question : ", terminator: "")
    guard let text = readLine(), !text.isEmpty else {
        print("Texte de question invalide.")
        return
    }
    
    var choices = [String]()
    for i in 1...4 {
        print("Entrez le choix \(i) : ", terminator: "")
        guard let choice = readLine(), !choice.isEmpty else {
            print("Choix invalide.")
            return
        }
        choices.append(choice)
    }
    
    print("Entrez l'index du choix correct (1-4) : ", terminator: "")
    guard let input = readLine(), let correctIndex = Int(input), (1...4).contains(correctIndex) else {
        print("Index de réponse invalide.")
        return
    }
    
    print("Entrez le niveau de difficulté de la question (1-3) : ", terminator: "")
    guard let difficultyInput = readLine(), let difficulty = Int(difficultyInput), (1...3).contains(difficulty) else {
        print("Niveau de difficulté invalide.")
        return
    }
    
    let question = Question(text: text, choices: choices, correctAnswerIndex: correctIndex - 1, difficulty: difficulty)
    quizQuestions.append(question)
    print("Question ajoutée avec succès !")
}

// Fonction pour démarrer l'éditeur de banque de questions
func startQuestionEditor() {
    while true {
        print("\nQue souhaitez-vous faire ?")
        print("1. Ajouter une nouvelle question")
        print("2. Quitter")
        print("Votre choix : ", terminator: "")
        
        guard let choice = readLine(), let option = Int(choice) else {
            print("Option invalide.")
            continue
        }
        
        switch option {
        case 1:
            addQuestion()
        case 2:
            startGame()
        default:
            print("Option invalide.")
        }
    }
}

// Démarrer le jeu ou l'éditeur de banque de questions en fonction de l'entrée de l'utilisateur
print("Choisissez l'option :")
print("1. Démarrer le jeu")
print("2. Éditeur de banque de questions")
print("Votre choix : ", terminator: "")
guard let choice = readLine(), let option = Int(choice) else {
    print("Option invalide.")
    exit(0)
}

switch option {
case 1:
    startGame()
case 2:
    startQuestionEditor()
default:
    print("Option invalide.")
}
