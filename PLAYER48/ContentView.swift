import SwiftUI
import Foundation
// MARK: - 5. SwiftUI View (界面)

struct ContentView: View {
    @StateObject private var viewModel = LiveViewModel()
    
    var body: some View {
        // 1. 使用 NavigationStack 替代 NavigationView
        Group{
            NavigationStack {
                // 2. 移除冗余的 Group，switch 直接作为 body 的内容
                switch viewModel.viewState {
                case .idle, .loading where viewModel.liveItems.isEmpty:
                    ProgressView("正在加载...")
                case .error(let message):
                    // 3. 提取错误视图为独立组件
                    ErrorFeedbackView(errorMessage: message) {
                        viewModel.fetchInitialData()
                    }
                case .loaded, .loading where !viewModel.liveItems.isEmpty:
                    // 4. 将列表内容提取为独立组件
                    LiveListView(viewModel: viewModel)
                // 如果有其他 ViewState，例如 .empty，可以添加在这里
                default:
                    // 确保所有 case 都被覆盖，这里默认会处理 unexpected 状态
                    Text("未知状态或正在处理数据...")
                }
        }
            .navigationTitle("直播列表")
            .onAppear {
                // 初始数据加载逻辑保持不变
                if viewModel.liveItems.isEmpty {
                    viewModel.fetchInitialData()
                }
            }
        }
    }
}
// MARK: - Subviews for Modularity
// 提取错误反馈视图
struct ErrorFeedbackView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(errorMessage)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button("重试", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
// 提取列表主体视图
struct LiveListView: View {
    @ObservedObject var viewModel: LiveViewModel // 使用 ObservedObject 接收 viewModel
    var body: some View {
        List {
            // 优化 ForEach 的分页触发逻辑，使用索引
            ForEach(Array(viewModel.liveItems.enumerated()), id: \.element.id) { index, item in
                LiveItemRow(item: item)
                    .onAppear {
                        // 滚动到倒数第 N 个时加载更多
                        // 使用索引直接判断，避免反复创建 ArraySlice
                        if index >= viewModel.liveItems.count - 5 && viewModel.nextID != nil {
                            viewModel.fetchMoreData()
                        }
                    }
                    // 确保列表项的 ID 正确，这里使用 item.id
            }
            // 列表底部加载指示器 (合并条件判断)
            // 5. 将底部加载指示器提取为独立视图
            //if viewModel.nextID != nil && viewModel.viewState == .loading {
            if viewModel.nextID != nil {
                LoadingMoreIndicatorView()
            }
        }
        .refreshable { // SwiftUI 自带的下拉刷新
            viewModel.fetchInitialData()
        }
    }
}
// 提取底部加载指示器视图
struct LoadingMoreIndicatorView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .padding(.vertical) // 增加一些垂直间距，让加载更明显
    }
}
// 简单的列表行视图 (保持不变，因为它已经很简洁)
struct LiveItemRow: View {
    let item: LiveItem
    var body: some View {
        HStack {
            // 可以放一个 AsyncImage 来加载封面
            // AsyncImage(url: URL(string: item.coverPath ?? ""), content: { image in
            //     image.resizable().scaledToFill()
            // }, placeholder: {
            //     Color.gray
            // })
            // .frame(width: 60, height: 60)
            // .cornerRadius(8)
            // .clipped()
            
            VStack(alignment: .leading) {
                Text(item.userInfo.nickname)
                    .font(.headline)
                Text(item.title ?? "无标题")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer() // 推开内容到左侧
        }
        .padding(.vertical, 4)
    }
}
struct LiveListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
