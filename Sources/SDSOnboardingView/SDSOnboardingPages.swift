//
//  SwiftUIView.swift
//
//  Created by : Tomoaki Yagishita on 2021/05/25
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import SwiftyUserDefaults

public class SDSOnboardingPages: ObservableObject {
    @Published public var shownPageNames = Defaults[\.shownPageNames]
    @Published public var introPages:[SDSOnboardingPage]
    
    public init(_ introViewInfoList: [SDSOnboardingPage]) {
        self.introPages = introViewInfoList
    }
    
    public func addIntroPage(_ newPage: SDSOnboardingPage) {
        self.introPages.append(newPage)
    }
    
    public func resetShownPageInfo() {
        shownPageNames = []
        Defaults[\.shownPageNames] = shownPageNames
    }
    
    public func storeShownPageInfo() {
        shownPageNames = introPages.map{$0.id}
        Defaults[\.shownPageNames] = shownPageNames
    }
    
    public func findNotShownPageIDs() -> [String] {
        var result:[String] = []
        for page in introPages {
            if !shownPageNames.contains(page.id) {
                result.append(page.id)
            }
        }
        if result.count == 0 {
            result.append(introPages[0].id)
        }
        return result
    }
    
    public func firstPageId() -> String {
        guard introPages.count > 0 else { return "" }
        return introPages[0].id
    }
    
    public func findNextPageID(of id: String ) -> String {
        if id == "" { return firstPageId() }
        guard let index = introPages.firstIndex(where: {$0.id == id}) else { return firstPageId() }
        let nextIndex = (index+1) < introPages.count ? index+1 : introPages.count-1
        return introPages[nextIndex].id
    }
    
    public func findPrevPageID(of id: String) -> String {
        if id == "" { return firstPageId() }
        guard let index = introPages.firstIndex(where: {$0.id == id}) else { return firstPageId() }
        let prevIndex = index > 0 ? index-1 : 0
        return introPages[prevIndex].id
    }
    
    public func needToShow() -> Bool {
        if shownPageNames.count < introPages.count {
            return true
        }
        return false
    }
    

}

extension DefaultsKeys {
    var shownPageNames:DefaultsKey<[String]> { .init("shownPageNames", defaultValue: [])}
}

public struct SDSOnboardingPage : Identifiable {
    public let id: String // page name, should be unique
    let content: () -> AnyView
    
    public init(name: String, @ViewBuilder content: @escaping () -> AnyView) {
        self.id = name
        self.content = content
    }
}
