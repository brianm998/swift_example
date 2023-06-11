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
                        NavigationLink(product.brand) {
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
        VStack {
            AsyncImage(url: URL(string: product.thumbnail))
            Text(product.brand)
            Text(product.description)
            Text("$\(product.price)")
        }
    }
}

extension ContentView {
    func loadProducts() {
        let url = "https://dummyjson.com/products"

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

            if let response = try? JSONDecoder().decode(ProductList.self, from: data) {
                DispatchQueue.main.async {
                    self.products = response.products
                }
            }
        }.resume()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
