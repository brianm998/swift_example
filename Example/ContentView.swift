//
//  ContentView.swift
//  Example
//
//  Created by Brian Martin on 6/11/23.
//

import SwiftUI


struct ProductList: Codable {
    let limit: Int
    let products: [Product]
    let skip: Int
    let total: Int
}

struct Product: Codable {
    let brand: String
    let category: String
    let description: String
    let discountPercentage: Double
    let id: Int
    let images: [String]        // url list
    let price: Int
    let rating: Double
    let stock: Int
    let thumbnail: String       // url
    let title: String
}

struct ContentView: View {

    @State var products: [Product] = []
    
    var body: some View {
        VStack {
            if products.count == 0 {
                Image(systemName: "globe")
                  .imageScale(.large)
                  .foregroundColor(.accentColor)
                Text("Loading")
            } else {
                NavigationStack {
                    List(products, id: \.id) { product in
                        NavigationLink(product.title) {
                            ProductDetail(product: product)                        
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadProducts) 
        .padding()
    }
}

struct ProductDetail: View {
    @State var product: Product

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("\(product.brand) \(product.title)")

                AsyncImage(url: URL(string: product.thumbnail)) { image in
                    image
                      .resizable()
                      .scaledToFill()
                } placeholder: {
                    Color.purple.opacity(0.1)
                }

                Text(product.description)
                Text("$\(product.price)")
                  .foregroundColor(.green)

                ScrollView(.horizontal) {
                    LazyHStack() {
                        ForEach(0..<product.images.count, id: \.self) { index in
                            AsyncImage(url: URL(string: product.images[index])) { image in
                                image
                                  .resizable()
                                  .scaledToFill()
                                  .cornerRadius(10)
                            } placeholder: {
                                Color.purple.opacity(0.1)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: 100)
            }
        }
    }
}

extension ContentView {
    func loadProducts() {
        let url = "https://dummyjson.com/products"
        loadCodableJson(from: url) { (response: ProductList) in
            self.products = response.products
        }
    }
}

func loadCodableJson<T>(from url: String, closure: @escaping (T)->Void) where T: Decodable {

    guard let url = URL(string: url) else {
        print("cannot construct url :(")
        return
    }
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            print("no data loaded from url")
            return
        }

        if let response = try? JSONDecoder().decode(T.self, from: data) {
            DispatchQueue.main.async {
                closure(response)
            }
        }
    }.resume()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
