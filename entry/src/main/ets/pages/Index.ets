import common from '@ohos.app.ability.common';
import { HdsTabs } from '@kit.UIDesignKit';
import { Board, Pin, Profile, RecommendationChip, RecommendationResult, RecommendationStatus } from '../models/InspirationModels';
import { DemoContentRepository } from '../services/DemoContentRepository';
import { BoardStorageService } from '../services/BoardStorageService';
import { HomePage } from './HomePage';
import { ExplorePage } from './ExplorePage';
import { InboxPage } from './InboxPage';
import { BoardsPage } from './BoardsPage';
import { SettingsPage } from './SettingsPage';
import { PinDetailPage } from './PinDetailPage';
import { BoardPicker } from '../components/BoardPicker';
import { NewBoardDialog } from '../components/NewBoardDialog';
import { PinOptionsSheet } from '../components/PinOptionsSheet';
import { PinShareSheet } from '../components/PinShareSheet';
import { PublishSheet } from '../components/PublishSheet';
import { ShareService } from '../services/ShareService';
import { DemoRecommendationProvider, RecommendationProvider } from '../services/RecommendationService';

enum ActiveSheet {
  None = 'none',
  Publish = 'publish',
  PinOptions = 'pin-options',
  Share = 'share'
}

@Entry
@Component
struct Index {
  @State private activeTab: number = 0;
  @State private searchText: string = '';
  @State private selectedPin?: Pin = undefined;
  @State private sheetPin?: Pin = undefined;
  @State private boards: Board[] = [];
  @State private savedPinIds: string[] = [];
  @State private showBoardPicker: boolean = false;
  @State private showNewBoardDialog: boolean = false;
  @State private activeSheet: ActiveSheet = ActiveSheet.None;
  @State private showSettings: boolean = false;
  @State private newBoardName: string = '';
  @State private feedbackMessage: string = '';
  @State private recommendationItems: RecommendationChip[] = [];
  @State private recommendationStatus: RecommendationStatus = RecommendationStatus.Loading;
  @State private selectedRecommendationId: string = 'demo-for-you';
  @State private homeRecommendationQuery: string = '';
  @State private homeResetKey: number = 0;
  @State private profile: Profile = {
    displayName: 'pinter',
    handle: 'torotarne',
    avatarInitial: 't',
    followerCount: 0,
    followingCount: 1
  };

  private readonly repository: DemoContentRepository = new DemoContentRepository();
  private readonly pins: Pin[] = this.repository.getPins();
  private readonly recommendationProvider: RecommendationProvider = new DemoRecommendationProvider(this.pins);

  aboutToAppear(): void {
    this.profile = this.repository.getProfile();
    this.loadLocalState();
    this.loadRecommendations();
  }

  onBackPress(): boolean {
    if (this.showNewBoardDialog) {
      this.showNewBoardDialog = false;
      this.newBoardName = '';
      return true;
    }
    if (this.showBoardPicker) {
      this.showBoardPicker = false;
      return true;
    }
    if (this.activeSheet !== ActiveSheet.None) {
      this.activeSheet = ActiveSheet.None;
      this.sheetPin = undefined;
      return true;
    }
    if (this.selectedPin) {
      this.closeDetail();
      return true;
    }
    if (this.showSettings) {
      this.closeSettings();
      return true;
    }
    return false;
  }

  private async loadRecommendations(): Promise<void> {
    try {
      const result: RecommendationResult = await this.recommendationProvider.loadRecommendations();
      this.recommendationItems = result.items;
      this.recommendationStatus = result.status;
    } catch (_error) {
      this.recommendationItems = [];
      this.recommendationStatus = RecommendationStatus.Error;
    }
  }

  private closeSettings(): void {
    this.activeTab = 4;
    this.showSettings = false;
  }

  private openRecommendation(item: RecommendationChip): void {
    this.selectedRecommendationId = item.id;
    this.homeRecommendationQuery = item.query;
  }

  private filteredHomePins(): Pin[] {
    const query = this.homeRecommendationQuery.trim().toLowerCase();
    if (query.length === 0) {
      return this.pins;
    }
    return this.pins.filter((pin: Pin): boolean => pin.category.toLowerCase() === query);
  }

  private async loadLocalState(): Promise<void> {
    const state = await BoardStorageService.load(getContext(this) as common.UIAbilityContext);
    this.boards = state.boards;
    this.savedPinIds = state.savedPinIds;
  }

  private async persistLocalState(): Promise<void> {
    const success = await BoardStorageService.save(getContext(this) as common.UIAbilityContext, {
      boards: this.boards,
      savedPinIds: this.savedPinIds
    });
    if (!success) {
      this.feedbackMessage = '本地保存失败，请重试';
    }
  }

  private filteredPins(): Pin[] {
    const keyword = this.searchText.trim().toLowerCase();
    if (keyword.length === 0) {
      return this.pins;
    }
    return this.pins.filter((pin: Pin): boolean => {
      const source = `${pin.title} ${pin.creator} ${pin.category} ${pin.description}`.toLowerCase();
      return source.indexOf(keyword) >= 0;
    });
  }

  private isSaved(pinId: string): boolean {
    return this.savedPinIds.indexOf(pinId) >= 0;
  }

  private openPin(pin: Pin): void {
    this.selectedPin = pin;
    this.feedbackMessage = '';
    this.activeSheet = ActiveSheet.None;
  }

  private openPinShare(pin: Pin): void {
    this.sheetPin = pin;
    this.activeSheet = ActiveSheet.Share;
    this.feedbackMessage = '';
  }

  private closeDetail(): void {
    this.selectedPin = undefined;
    this.sheetPin = undefined;
    this.showBoardPicker = false;
    this.activeSheet = ActiveSheet.None;
  }

  private handlePinOption(action: string): void {
    this.activeSheet = ActiveSheet.None;
    if (action === 'follow') {
      this.feedbackMessage = '关注功能暂不可用';
    } else if (action === 'copy') {
      this.feedbackMessage = '复制链接功能暂不可用：当前灵感没有真实链接';
    } else if (action === 'download') {
      this.feedbackMessage = '下载图片功能暂不可用：当前内容为演示绘制';
    } else if (action === 'hide') {
      this.feedbackMessage = '隐藏功能暂不可用';
    } else if (action === 'report') {
      this.feedbackMessage = '举报功能暂不可用';
    } else {
      this.feedbackMessage = '该操作暂不可用';
    }
  }

  private async shareSelectedPin(): Promise<void> {
    const selectedPin = this.sheetPin ? this.sheetPin : this.selectedPin;
    if (!selectedPin) {
      return;
    }
    const success = await ShareService.sharePin(
      getContext(this) as common.UIAbilityContext,
      selectedPin
    );
    this.activeSheet = ActiveSheet.None;
    if (!success) {
      this.feedbackMessage = '暂时无法打开系统分享';
    }
  }

  private handleShareAction(action: string): void {
    if (action === 'send' || action === 'more') {
      this.shareSelectedPin();
      return;
    }
    this.activeSheet = ActiveSheet.None;
    if (action === 'copy') {
      this.feedbackMessage = '复制链接功能暂不可用：当前灵感没有真实链接';
    } else if (action === 'download') {
      this.feedbackMessage = '下载图片功能暂不可用：当前内容为演示绘制';
    } else if (action === 'hide') {
      this.feedbackMessage = '隐藏功能暂不可用';
    } else if (action === 'report') {
      this.feedbackMessage = '举报功能暂不可用';
    } else {
      this.feedbackMessage = '该应用分享入口暂未配置';
    }
  }

  private saveToBoard(boardId: string): void {
    const selectedPin = this.selectedPin;
    if (!selectedPin) {
      return;
    }
    const selectedId = selectedPin.id;
    this.boards = this.boards.map((board: Board): Board => {
      if (board.id !== boardId || board.pinIds.indexOf(selectedId) >= 0) {
        return board;
      }
      return {
        id: board.id,
        name: board.name,
        pinIds: [...board.pinIds, selectedId],
        createdAt: board.createdAt
      };
    });
    if (!this.isSaved(selectedId)) {
      this.savedPinIds = [...this.savedPinIds, selectedId];
    }
    this.showBoardPicker = false;
    this.feedbackMessage = '已收藏到画板';
    this.persistLocalState();
  }

  private createBoard(): void {
    const name = this.newBoardName.trim();
    if (name.length === 0) {
      this.feedbackMessage = '请先输入画板名称';
      return;
    }
    const selectedId = this.selectedPin ? this.selectedPin.id : '';
    const board: Board = {
      id: `board-${Date.now()}`,
      name,
      pinIds: selectedId.length > 0 ? [selectedId] : [],
      createdAt: Date.now()
    };
    this.boards = [...this.boards, board];
    if (selectedId.length > 0 && !this.isSaved(selectedId)) {
      this.savedPinIds = [...this.savedPinIds, selectedId];
    }
    this.newBoardName = '';
    this.showNewBoardDialog = false;
    this.showBoardPicker = false;
    this.feedbackMessage = selectedId.length > 0 ? '已新建画板并收藏' : '画板已新建';
    this.persistLocalState();
  }

  private openPublishSheet(): void {
    this.activeSheet = ActiveSheet.Publish;
  }

  private relatedPinsFor(pin: Pin): Pin[] {
    return this.pins.filter((item: Pin): boolean => item.id !== pin.id);
  }

  @Builder
  private buildPublishSheet() {
    PublishSheet()
  }

  @Builder
  private buildPinDetail(pin: Pin) {
    PinDetailPage({
      pin: pin,
      relatedPins: this.relatedPinsFor(pin),
      saved: this.isSaved(pin.id),
      feedbackMessage: this.feedbackMessage,
      onBack: () => this.closeDetail(),
      onSave: () => {
        this.showBoardPicker = true;
        this.feedbackMessage = '';
      },
      onMore: () => {
        this.activeSheet = ActiveSheet.PinOptions;
        this.feedbackMessage = '';
      },
      onShare: () => {
        this.openPinShare(pin);
      },
      onRelatedOpen: (relatedPin: Pin) => this.openPin(relatedPin),
      onFeedback: (message: string) => this.feedbackMessage = message
    })
  }

  @Builder
  private buildPinOptions(pin: Pin) {
    PinOptionsSheet({
      creator: pin.creator,
      onClose: () => this.activeSheet = ActiveSheet.None,
      onAction: (action: string) => this.handlePinOption(action)
    })
  }

  @Builder
  private buildShareSheet(pin: Pin) {
    PinShareSheet({
      pin: pin,
      onAction: (action: string) => this.handleShareAction(action)
    })
  }

  @Builder
  private buildActiveSheet() {
    if (this.activeSheet === ActiveSheet.PinOptions) {
      this.buildPinOptions(this.selectedPin ? this.selectedPin : this.pins[0]);
    } else if (this.activeSheet === ActiveSheet.Share) {
      this.buildShareSheet(this.sheetPin ? this.sheetPin : (this.selectedPin ? this.selectedPin : this.pins[0]));
    } else {
      this.buildPublishSheet();
    }
  }

  @Builder
  private buildTabBar(label: string, index: number) {
    Column({ space: 2 }) {
      if (index === 0) {
        Image($r(this.activeTab === index ? 'app.media.lucide_home_active' : 'app.media.lucide_home'))
          .width(24)
          .height(24)
      } else if (index === 1) {
        Image($r(this.activeTab === index ? 'app.media.lucide_search_active' : 'app.media.lucide_search'))
          .width(24)
          .height(24)
      } else if (index === 3) {
        Image($r(this.activeTab === index ? 'app.media.lucide_inbox_active' : 'app.media.lucide_inbox'))
          .width(24)
          .height(24)
      } else {
        Image($r(this.activeTab === index ? 'app.media.lucide_user_round_active' : 'app.media.lucide_user_round'))
          .width(24)
          .height(24)
      }
      Text(label)
        .fontSize(11)
        .lineHeight(14)
        .fontWeight(this.activeTab === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.activeTab === index ? '#202124' : '#70757A')
        .margin({ top: 2 })
        .height(14)
        .maxLines(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .offset({ x: this.tabBarHorizontalOffset(index) })
    .onClick(() => {
      this.activeTab = index;
    })
    .gesture(TapGesture({ count: 2 }).onAction(() => {
      if (index === 0) {
        this.activeTab = 0;
        this.homeResetKey += 1;
      }
    }))
    .accessibilityText(label)
  }

  private tabBarHorizontalOffset(index: number): string {
    if (index === 0) {
      return '-10%';
    }
    if (index === 1) {
      return '-30%';
    }
    if (index === 3) {
      return '30%';
    }
    return '10%';
  }

  private contentIndexForActiveTab(): number {
    return this.activeTab <= 1 ? this.activeTab : this.activeTab - 1;
  }

  private tabIndexForContentIndex(index: number): number {
    return index <= 1 ? index : index + 1;
  }

  @Builder
  private buildPublishButton() {
    Button({ type: ButtonType.Circle }) {
      Image($r('app.media.lucide_plus'))
        .width(24)
        .height(24)
    }
    .width(44)
    .height(44)
    .margin({ bottom: 34 })
    .backgroundColor('#E60023')
    .onClick(() => {
      this.openPublishSheet();
    })
    .accessibilityText('发布')
    .zIndex(2)
  }

  @Builder
  private buildRootPage() {
    Stack({ alignContent: Alignment.Bottom }) {
      HdsTabs({ barPosition: BarPosition.End, index: this.contentIndexForActiveTab() }) {
        TabContent() {
          HomePage({
            pins: this.filteredHomePins(),
            recommendations: this.recommendationItems,
            recommendationStatus: this.recommendationStatus,
            selectedRecommendationId: this.selectedRecommendationId,
            resetKey: this.homeResetKey,
            onOpenPin: (pin: Pin) => this.openPin(pin),
            onSharePin: (pin: Pin) => this.openPinShare(pin),
            onRecommendationClick: (item: RecommendationChip) => this.openRecommendation(item)
          })
        }.tabBar(this.buildTabBar('首页', 0))

        TabContent() {
          ExplorePage({
            pins: this.filteredPins(),
            searchText: this.searchText,
            onSearchChange: (value: string) => this.searchText = value,
            onOpenPin: (pin: Pin) => this.openPin(pin),
            onSharePin: (pin: Pin) => this.openPinShare(pin)
          })
        }.tabBar(this.buildTabBar('发现', 1))

        TabContent() {
          InboxPage()
        }.tabBar(this.buildTabBar('收件箱', 3))

        TabContent() {
          BoardsPage({
            boards: this.boards,
            pins: this.pins,
            savedPinIds: this.savedPinIds,
            profile: this.profile,
            onOpenSettings: () => this.showSettings = true
          })
        }.tabBar(this.buildTabBar('我的', 4))
      }
      .width('100%')
      .height('100%')
      .vertical(false)
      .barOverlap(true)
      .barHeight(56)
      .barFloatingStyle({ barBottomMargin: 28 })
      .animationDuration(250)
      .onTabBarClick((index: number) => {
        this.activeTab = this.tabIndexForContentIndex(index);
      })
      .onChange((index: number) => {
        this.activeTab = this.tabIndexForContentIndex(index);
      })
      .backgroundColor(Color.White)

      this.buildPublishButton()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.selectedPin) {
        this.buildPinDetail(this.selectedPin)
      } else if (this.showSettings) {
        SettingsPage({
          onBack: () => this.closeSettings(),
          onExit: () => this.closeSettings()
        })
      } else {
        this.buildRootPage()
      }

      if (this.showBoardPicker) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.36)')
          .onClick(() => this.showBoardPicker = false)
        Column() {
          Blank().layoutWeight(1)
          BoardPicker({
            boards: this.boards,
            onClose: () => this.showBoardPicker = false,
            onSave: (boardId: string) => this.saveToBoard(boardId),
            onCreateBoard: () => this.showNewBoardDialog = true
          })
        }
        .width('100%')
        .height('100%')
      }

      if (this.showNewBoardDialog) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.36)')
          .onClick(() => this.showNewBoardDialog = false)
        NewBoardDialog({
          newBoardName: this.newBoardName,
          feedbackMessage: this.feedbackMessage,
          onNameChange: (value: string) => this.newBoardName = value,
          onClose: () => {
            this.showNewBoardDialog = false;
            this.newBoardName = '';
          },
          onCreate: () => this.createBoard()
        })
      }

    }
    .width('100%')
    .height('100%')
    .bindSheet(this.activeSheet !== ActiveSheet.None, this.buildActiveSheet(), {
      height: SheetSize.FIT_CONTENT,
      detents: [SheetSize.FIT_CONTENT],
      dragBar: true,
      showClose: true,
      title: {
        title: this.activeSheet === ActiveSheet.PinOptions ? '选项' :
          (this.activeSheet === ActiveSheet.Share ? '分享到' : '立即开始创作')
      },
      backgroundColor: Color.White,
      maskColor: this.activeSheet === ActiveSheet.Publish ? '#66000000' : '#99000000',
      onDisappear: () => {
        this.activeSheet = ActiveSheet.None;
        this.sheetPin = undefined;
      }
    })
  }
}
