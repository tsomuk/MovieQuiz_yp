import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - IBOutlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    private let questionsAmount : Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion : QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService : StatisticService?
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        statisticService = StatisticServiceImpl()
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
   
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            
        }
    }
    
    
    
    
    // MARK: - Buttons
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let givenAnswer = false
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Funcs
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.cornerRadius = 20
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {

    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
      } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount )

        
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен"!",
            message: makeResultMessange(),
            buttonText: "Сыграть еще раз",
            buttonAction: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )

        alertPresenter?.show(alertModel: alertModel)
        
        
    }
                             
    private func makeResultMessange() -> String {
          
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error messange")
            return ""
        }
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccurancyLine = "Средня точность: \(String(format: "%.2f", statisticService.totalAccurancy))%"
        
        
        let resultMessange = [
        currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccurancyLine
        ].joined(separator: "\n")
        
        return resultMessange
        
        }
}



//let text = correctAnswers == questionsAmount ?
//            "Поздравляем, Вы ответили на 10 из 10!" :
//            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
//let viewModel = QuizResultsViewModel(
//    title: "Этот раунд окончен!",
//    text: text,
//    buttonText: "Сыграть ещё раз")
//show(quiz: viewModel)
