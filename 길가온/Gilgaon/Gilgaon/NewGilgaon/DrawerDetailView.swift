//
//  DrawerDetailView.swift
//  Gilgaon
//
//  Created by 정소희 on 2023/03/04.
//

import SwiftUI

struct DrawerDetailView: View {
    
    @AppStorage("isRecording") var isRecordingStatus: Bool = UserDefaults.standard.bool(forKey: "isRecording")
    @EnvironmentObject var fireStoreViewModel: FireStoreViewModel
    @StateObject var friendViewModel = FriendViewModel()
    @State private var middleView: MiddleView = .schedule
    @Binding var showMenu: Bool
    // 프로필 편집 모드
    @State private var photoEditing: Bool = false
    @State private var showPicker: Bool = false
    @State private var profileImage: UIImage? = nil
    @State var userProfile: FireStoreModel?
    @State var selectRecording = false
    var middleViewArray: [MiddleView] = [.schedule, .list]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    // profile Image
                    Spacer()
                    VStack {
                        
                        ZStack {
                            Button {
                                photoEditing.toggle()
                            } label: {
                                
                                if profileImage == nil {
                                    if let url = fireStoreViewModel.profileUrlString,
                                       let imageUrl = URL(string: url) {
                                        AsyncImage(url: imageUrl) { image in
                                            image
                                                .resizable()
                                                .clipShape(Circle())
                                                .frame(width: 110, height: 110)
                                                .overlay(RoundedRectangle(cornerRadius: 64)
                                                    .stroke(Color("Pink"), lineWidth: 3))
                                            
                                        } placeholder: {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color("Pink"))
                                                .frame(width: 110, height: 110)
                                                .aspectRatio(contentMode: .fit)
                                        }
                                    } else {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("Pink"))
                                            .frame(width: 110, height: 110)
                                    }
                                } else {
                                    if profileImage != nil {
                                        Image(uiImage: profileImage!)
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: 110, height: 110)
                                            .overlay(RoundedRectangle(cornerRadius: 64)
                                                .stroke(Color("Pink"), lineWidth: 3))
                                    } else {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("Pink"))
                                            .frame(width: 110, height: 110)
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                                
                            }
                            
                            VStack {
                                // MARK: 프로필 편집 모드 On
                                if photoEditing == true {
                                    HStack(spacing: 10) {
                                        // 선택된 이미지가 없는 경우
                                        if profileImage == nil {
                                            // 사진 선택 버튼
                                            Button {
                                                showPicker.toggle()
                                            } label: {
                                                Text("선택")
                                                    .font(.custom("NotoSerifKR-Regular",size:12))
                                            }
                                            
                                            // 선택된 이미지가 없는 경우
                                        } else {
                                            // 선택 완료 버튼
                                            Button {
                                                photoEditing = false
                                                let userProfile = FireStoreModel(id: fireStoreViewModel.info?.id ?? "", nickName: fireStoreViewModel.userNickName, userPhoto: fireStoreViewModel.info?.userPhoto ?? "", userEmail: fireStoreViewModel.info?.userEmail ?? "")
                                                Task{
                                                    await fireStoreViewModel.uploadImageToStorage(userImage: profileImage, user: userProfile)
                                                }
                                            } label: {
                                                Text("완료")
                                                    .font(.custom("NotoSerifKR-Regular",size:12))
                                            }
                                            
                                        }
                                        
                                        // 선택 취소 버튼
                                        Button(action: {
                                            photoEditing = false
                                            profileImage = nil
                                        }) {
                                            Text("취소")
                                                .font(.custom("NotoSerifKR-Regular",size:12))
                                        }
                                        
                                    }
                                }
                            }
                            .offset(y: 70)
                        }
 
                    }
                    //                        .offset(x: -65)
                    Spacer()
                    VStack(alignment: .leading) {
                        
                        userNickNameText // fireStoreViewModel.userNickName
                        
                        NavigationLink {
//                            AddFriendView(friendViewModel: friendViewModel)
                            FriendSettingView()
                        } label: {
                            Text("\(fireStoreViewModel.myFriendArray.count)명의 친구")
                                .font(.custom("NotoSerifKR-Regular",size:16))
                            
                        }
                        Text(isRecordingStatus ? "기록중" : "기록안하는중")
                        
                    }
                    Spacer()
                }
                
                HStack {
                    ForEach(middleViewArray, id: \.self) { select in
                        ZStack {
                            Button {
                                middleView = select
                            } label: {
                                Text(select.rawValue)
                                    .foregroundColor(middleView == select ? Color("Pink") : Color("DarkGray"))
                                    .font(.custom("NotoSerifKR-Regular",size:16))
                            }
                            
                            
                            if middleView == select {
                                Capsule()
                                    .foregroundColor(Color("Red"))
                                    .frame(height: 3)
                                    .offset(y: 17)
                            }
                            
                        }
                        .frame(width: geometry.size.width/2.4)
                    }
                }
                
                switch middleView {
                case .schedule:
                    DrawerScheduleView()
                case .list:
                    DrawerListView()
                }
            }
            .fullScreenCover(isPresented: $showPicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
}

extension DrawerDetailView {
    
    private var personImage: some View {
        Image(systemName: "person.fill")
            .foregroundColor(Color("Pink"))
            .font(.system(size: 64))
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 64)
                .stroke(Color("Pink"), lineWidth: 3))
    }
    
    private var userNickNameText: some View {
        Text(fireStoreViewModel.userNickName)
            .font(.custom("NotoSerifKR-Regular",size:25))
            .foregroundColor(Color("DarkGray"))
            .bold()
            .padding(.bottom, 10)
    }
    
    
    // 보류
    @ViewBuilder
    private func recordButton() -> some View {
        if !selectRecording {
            Button {
                selectRecording.toggle()
            } label: {
                Text("기록하기")
            }

        }else{
            HStack{
                Button {
                    selectRecording.toggle()
                } label: {
                    Text("기록완료")
                }
                
                Button {
                    
                } label: {
                    Text("마커찍기")
                }
            }
        }
    }
    
}

struct DrawerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DrawerDetailView(showMenu: .constant(true))
    }
}
