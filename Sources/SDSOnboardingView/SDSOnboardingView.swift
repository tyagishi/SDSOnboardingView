//
//  SwiftUIView.swift
//
//  Created by : Tomoaki Yagishita on 2021/05/25
//  © 2021  SmallDeskSoftware
//

import SwiftUI

public struct SDSOnboardingView: View {
    @Binding var present:Bool
    @ObservedObject var introPages: SDSOnboardingPages
    let viewSize:CGSize // valid only for macOS
    @State var selectedPageID: String

    
    public init(isPresented: Binding<Bool>, _ introPages: SDSOnboardingPages,_ viewSize: CGSize = .zero) {
        #if os(iOS)
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        #endif
        self._present = isPresented
        self.introPages = introPages
        self.viewSize = viewSize
        self._selectedPageID = State(wrappedValue: introPages.findNotShownPageIDs().first!)

    }
    
    public var body: some View {
        VStack {
            #if os(iOS)
            LocalTabView(introPages)
                .tabViewStyle(PageTabViewStyle())
            #elseif os(macOS)
            ZStack {
                TabView(selection: $selectedPageID) {
                    ForEach(introPages.introPages) { viewInfo in
                        viewInfo.content()
                            .tabItem { Text(viewInfo.id) }
                            .tag(viewInfo.id)
                    }
                }
                HStack { // prev/next button
                    Image(systemName: "arrow.left.circle")
                        .resizable().scaledToFit()
                        .frame(width: 50, height: 50)
                        .opacity(0.5)
                        .onTapGesture {
                            selectedPageID = introPages.findPrevPageID(of: selectedPageID)
                        }
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .resizable().scaledToFit()
                        .frame(width: 50, height: 50)
                        .opacity(0.5)
                        .onTapGesture {
                            selectedPageID = introPages.findNextPageID(of: selectedPageID)
                        }
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
            .frame(width: viewSize.width, height: viewSize.height)
            #endif
            HStack {
                Button("later") {
                    // user can come back to same intro
                    present.toggle()
                }
                .padding(.leading, 30)
                Spacer()
                Text(introPages.descriptionFor(page: selectedPageID))
                Spacer()
                Button("close") {
                    present.toggle()
                    introPages.storeShownPageInfo()
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            if introPages.introPages.count == 0 {
                present = false
            }
        }
    }
}

struct LocalTabView: View {
    let introPages: SDSOnboardingPages
    @State var selectedPageID: String
    
    init(_ pages: SDSOnboardingPages) {
        self.introPages = pages
        _selectedPageID = State(wrappedValue: introPages.findNotShownPageIDs().first!)
    }
    var body: some View {
        ZStack {
            TabView(selection: $selectedPageID) {
                ForEach(introPages.introPages) { viewInfo in
                    viewInfo.content()
                        .tabItem { Text(viewInfo.id) }
                        .tag(viewInfo.id)
                }
            }
            #if os(macOS)
            HStack { // prev/next button
                Image(systemName: "arrow.left.circle")
                    .resizable().scaledToFit()
                    .frame(width: 50, height: 50)
                    .opacity(0.5)
                    .onTapGesture {
                        selectedPageID = introPages.findPrevPageID(of: selectedPageID)
                    }
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .resizable().scaledToFit()
                    .frame(width: 50, height: 50)
                    .opacity(0.5)
                    .onTapGesture {
                        selectedPageID = introPages.findNextPageID(of: selectedPageID)
                    }
            }
            #endif
        }
    }
    
}

struct SDSOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        SDSOnboardingView(isPresented: .constant(true),  SDSOnboardingPages([SDSOnboardingPage(name: "view1", content: { AnyView(Text("test"))})]))
    }
}
