import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {  
 
    // MARK: - Properties
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
    }

    // MARK: - Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз",
            buttonAction: { [weak self] in guard let self = self else {return}
                
                self.imageView.image = UIImage(named: "Loading")
                self.presenter.restartGame()
            })
        alertPresenter?.show(alertModel: model)
    }
    
    func showFinalResults() {
        imageView.layer.borderColor = nil
        imageView.image = UIImage(named: "Loading")
        alertPresenter?.show(alertModel: presenter.createFinalResultsAlerModel())
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesAndNoButtonsActivation(nowItIs: false)
    }
    
    func yesAndNoButtonsActivation(nowItIs: Bool) {
        yesButton.isEnabled = nowItIs
        noButton.isEnabled = nowItIs
    }
    
  
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
   
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
