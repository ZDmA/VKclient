//
//  ViewController.swift
//  VKClient
//
//  Created by Дмитрий on 08.08.2022.
//

import UIKit
import Alamofire
import WebKit


class ViewController: UIViewController {
    var isAuthorizedVK: Bool = false

    @IBOutlet weak var webView: WKWebView!  {
        didSet{
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        guard let request = createURLRequestVKAutorization() else {
            print("Некорректный URL VKAutorization")
            return
        }
        webView.load(request)
    }

//MARK: createURLVKgroupsById
    func createURLVKgroupsById () -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/groups.getById"
        urlComponents.queryItems = [
            URLQueryItem(name: "group_ids",     value: "n_mikhalkov_besogon"),
            URLQueryItem(name: "fields",        value: "description"),
            URLQueryItem(name: "access_token",  value: VKSession.shared.token),
            URLQueryItem(name: "v",             value: "5.131")
        ]

        return urlComponents.url
    }

    //MARK: createURLVKgroupsGet
    func createURLVKgroupsGet () -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/groups.get"
        urlComponents.queryItems = [
            URLQueryItem(name: "extended",      value: "1"),
            URLQueryItem(name: "access_token",  value: VKSession.shared.token),
            URLQueryItem(name: "v",             value: "5.131")
        ]

        return urlComponents.url
    }


//MARK: createURLVKphotosGetAll
    func createURLVKphotosGetAll () -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/photos.getAll"
        urlComponents.queryItems = [
            URLQueryItem(name: "owner_id",      value: "-1"),
            URLQueryItem(name: "access_token",  value: VKSession.shared.token),
            URLQueryItem(name: "v",             value: "5.131")
        ]

        return urlComponents.url
    }

//MARK: createURLVKgetFriends
    func createURLVKgetFriends () -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/friends.get"
        urlComponents.queryItems = [
            //URLQueryItem(name: "user_id",       value: VKSession.shared.client_id),
            URLQueryItem(name: "order",         value: "random"),
            URLQueryItem(name: "fields",        value: "nickname, bdate"),
            URLQueryItem(name: "name_case",     value: "nom"),
            URLQueryItem(name: "access_token",  value: VKSession.shared.token),
            URLQueryItem(name: "v",             value: "5.131")
        ]

        return urlComponents.url
    }

//MARK: createURLRequestVKAutorization
    func createURLRequestVKAutorization () -> URLRequest?{
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id",     value: VKSession.shared.client_id),
            URLQueryItem(name: "display",       value: "mobile"),
            URLQueryItem(name: "redirect_uri",  value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope",         value: "262150"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v",             value: "5.131")
        ]
        guard let urlVKAutorization = urlComponents.url else {
            return nil
        }
        return URLRequest(url: urlVKAutorization)
    }
}

//MARK: extension ViewController: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url,
                url.path == "/blank.html",
                let fragment = url.fragment else {
                    decisionHandler(.allow)
                    print("Проверка, получены ли данные в ответе")
                    return
                }

        print("Get answer, find token")
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        guard let token = params["access_token"] else {
            print("Не получен access_token")
            return
        }

        VKSession.shared.token = token
        print("access_token=", VKSession.shared.token)
        decisionHandler(.cancel)
//---
        guard let someURL = createURLVKgetFriends() else {
            print("Некорректный URL VKgetFriends")
            return
        }

        AF.request(someURL, method: .get).responseJSON { response in
            print(response.value)
        }
//---
        guard let someURL = createURLVKphotosGetAll() else {
            print("Некорректный URL VKgetFriends")
            return
        }

        AF.request(someURL, method: .get).responseJSON { response in
            print(response.value)
        }
//---
        guard let someURL = createURLVKgroupsGet() else {
            print("Некорректный URL VKgroupsGet")
            return
        }

        AF.request(someURL, method: .get).responseJSON { response in
            print(response.value)
        }
//---
        guard let someURL = createURLVKgroupsById() else {
            print("Некорректный URL VKgroupsById")
            return
        }

        AF.request(someURL, method: .get).responseJSON { response in
            print(response.value)
        }
    }
}
