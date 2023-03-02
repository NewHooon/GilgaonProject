//
//  DrawerListView.swift
//  Gilgaon
//  Created by zooey on 2022/12/19.
//

import SwiftUI

struct DrawerListView: View {
    
    @StateObject private var firestoreViewModel = FireStoreViewModel()
    
    var body: some View {
        
        ZStack {
            Color("White")
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(firestoreViewModel.calendarList){ value in
                        NavigationLink(destination: FlowerMapView(fireStoreViewModel: firestoreViewModel,getStringValue: value.id)) {
                            taskCardView(task: value)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear{
            firestoreViewModel.fetchDayCalendar()
        }
    }
    
    func taskCardView(task: DayCalendarModel) -> some View {
        
        HStack(alignment: .top, spacing: 30) {
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(task.title)
                            .font(.custom("NotoSerifKR-Bold", size: 19))
                    }
                    .hLeading()
                    
                    // 생성 날짜
                    Text(task.createdDate)
                    
                    // 기록 수정 삭제 기능 추가해야함(밀어서 삭제하기)
                    
                }
                
                HStack(spacing: 0) {
                    HStack(spacing: -10) {
                        
                        //친구들 프사 추가하는거(shareFriend에 친구 아이디가 추가되면 아이디를 가지고 이미지를 가져와야함)
                        ForEach(["p2", "p3", "p4"], id: \.self) { user in
                            
                            Image(user)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .stroke(Color("DarkGray"), lineWidth: 2)
                                )
                            
                        }
                    }
                    .hLeading()
                }
                .padding(.top)
                
            }
            .foregroundColor(Color("DarkGray"))
            .padding()
            .hLeading()
            .background(
                Color("Pink")
                    .cornerRadius(25)
                    .opacity(0.4)
            )
        }
        .hLeading()
    }
}

struct DrawerListView_Previews: PreviewProvider {
    static var previews: some View {
        DrawerListView()
    }
}
