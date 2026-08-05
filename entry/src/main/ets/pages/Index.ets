import common from '@ohos.app.ability.common';
import { curves } from '@kit.ArkUI';
import { HdsTabs } from '@kit.UIDesignKit';
import { Board, Pin, Profile } from '../models/InspirationModels';
import { BoardStorageService } from '../services/BoardStorageService';
import { HomePage } from './HomePage';
import { ExplorePage } from './ExplorePage';
import { InboxPage } from './InboxPage';
import { BoardsPage } from './BoardsPage';
import { SettingsPage } from './SettingsPage';
import { PinDetailPage } from './PinDetailPage';
import { BoardFlowSheet } from '../components/BoardFlowSheet';
import { PinOptionsSheet } from '../components/PinOptionsSheet';
import { PinShareSheet } from '../components/PinShareSheet';
import { PublishSheet } from '../components/PublishSheet';
import { RelatedPinsSheet } from '../components/RelatedPinsSheet';
import { ShareService } from '../services/ShareService';

enum ActiveSheet {
  None = 'none',
  Publish = 'publish',
  PinOptions = 'pin-options',
  Share = 'share',
  BoardPicker = 'board-picker',
  RelatedPins = 'related-pins'
}

enum BoardSheetMode {
  Picker = 'picker',
  NewBoard = 'new-board'
}

@Entry
@Component
struct Index {
  @State private activeTab: number = 0;
  @State private searchText: string = '';
  @State private selectedPin?: Pin = undefined;
  @State private detailPinStack: Pin[] = [];
  @State private detailRouteKey: number = 0;
  @State private likedPinIds: string[] = [];
  @State private sheetPin?: Pin = undefined;
  @State private boards: Board[] = [];
  @State private savedPinIds: string[] = [];
  @State private activeSheet: ActiveSheet = ActiveSheet.None;
  @State private boardSheetMode: BoardSheetMode = BoardSheetMode.Picker;
  @State private showSettings: boolean = false;
  @State private newBoardName: string = '';
  @State private feedbackMessage: string = '';
  @State private homeResetKey: number = 0;
  @State private profile: Profile = {
    displayName: '未登录',
    handle: '账号功能暂未接入',
    avatarInitial: '',
    followerCount: 0,
    followingCount: 0
  };

  private readonly pins: Pin[] = [];

  private pageSettleTransition(): TransitionEffect {
    return TransitionEffect.translate({ x: '8%' })
      .animation({ curve: curves.springMotion(0.42, 0.9, 0.16) })
      .combine(TransitionEffect.OPACITY.animation({ duration: 140, curve: Curve.LinearOutSlowIn }));
  }

  private bottomSurfaceTransition(): TransitionEffect {
    return TransitionEffect.translate({ y: 48 })
      .animation({ curve: curves.springMotion(0.38, 0.88, 0.16) })
      .combine(TransitionEffect.OPACITY.animation({ duration: 140, curve: Curve.LinearOutSlowIn }));
  }

  aboutToAppear(): void {
    this.loadLocalState();
  }

  onBackPress(): boolean {
    if (this.activeSheet === ActiveSheet.BoardPicker && this.boardSheetMode === BoardSheetMode.NewBoard) {
      this.returnToBoardPicker();
      return true;
    }
    if (this.activeSheet !== ActiveSheet.None) {
      this.closeActiveSheet();
      return true;
    }
    if (this.selectedPin) {
      this.backFromDetail();
      return true;
    }
    if (this.showSettings) {
      this.closeSettings();
      return true;
    }
    return false;
  }

  private closeSettings(): void {
    this.activeTab = 4;
    this.showSettings = false;
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

  private isLiked(pinId: string): boolean {
    return this.likedPinIds.indexOf(pinId) >= 0;
  }

  private toggleLike(pinId: string): void {
    if (this.isLiked(pinId)) {
      this.likedPinIds = this.likedPinIds.filter((id: string): boolean => id !== pinId);
      return;
    }
    this.likedPinIds = [...this.likedPinIds, pinId];
  }

  private openPin(pin: Pin): void {
    this.detailPinStack = [pin];
    this.selectedPin = pin;
    this.detailRouteKey += 1;
    this.feedbackMessage = '';
    this.activeSheet = ActiveSheet.None;
  }

  private openRelatedPin(pin: Pin): void {
    if (!this.selectedPin || this.detailPinStack.length === 0) {
      this.openPin(pin);
      return;
    }
    this.detailPinStack = [...this.detailPinStack, pin];
    this.selectedPin = pin;
    this.detailRouteKey += 1;
    this.feedbackMessage = '';
    this.closeActiveSheet();
  }

  private openPinShare(pin: Pin): void {
    this.sheetPin = pin;
    this.activeSheet = ActiveSheet.Share;
    this.feedbackMessage = '';
  }

  private closeDetail(): void {
    this.selectedPin = undefined;
    this.detailPinStack = [];
    this.sheetPin = undefined;
    this.activeSheet = ActiveSheet.None;
  }

  private backFromDetail(): void {
    if (this.detailPinStack.length <= 1) {
      this.closeDetail();
      return;
    }
    const previousStack = this.detailPinStack.slice(0, this.detailPinStack.length - 1);
    this.detailPinStack = previousStack;
    this.selectedPin = previousStack[previousStack.length - 1];
    this.detailRouteKey += 1;
    this.feedbackMessage = '';
    this.closeActiveSheet();
  }

  private handlePinOption(action: string): void {
    this.activeSheet = ActiveSheet.None;
    if (action === 'follow') {
      this.feedbackMessage = '关注功能暂不可用';
    } else if (action === 'copy') {
      this.feedbackMessage = '复制链接功能暂不可用：当前灵感没有真实链接';
    } else if (action === 'download') {
      this.feedbackMessage = '下载图片功能暂不可用：当前没有可下载内容';
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
      this.feedbackMessage = '下载图片功能暂不可用：当前没有可下载内容';
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
    this.closeActiveSheet();
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
    this.closeActiveSheet();
    this.feedbackMessage = selectedId.length > 0 ? '已新建画板并收藏' : '画板已新建';
    this.persistLocalState();
  }

  private openPublishSheet(): void {
    this.activeSheet = ActiveSheet.Publish;
  }

  private openRelatedPins(): void {
    if (!this.selectedPin) {
      return;
    }
    this.sheetPin = this.selectedPin;
    this.activeSheet = ActiveSheet.RelatedPins;
  }

  private openNewBoardSheet(): void {
    this.newBoardName = '';
    this.feedbackMessage = '';
    this.boardSheetMode = BoardSheetMode.NewBoard;
  }

  private returnToBoardPicker(): void {
    this.newBoardName = '';
    this.feedbackMessage = '';
    this.boardSheetMode = BoardSheetMode.Picker;
    this.activeSheet = ActiveSheet.BoardPicker;
  }

  private closeActiveSheet(): void {
    this.boardSheetMode = BoardSheetMode.Picker;
    this.activeSheet = ActiveSheet.None;
    this.sheetPin = undefined;
  }

  private relatedPinsFor(pin: Pin): Pin[] {
    return this.pins.filter((item: Pin): boolean => item.id !== pin.id);
  }

  @Builder
  private buildPublishSheet() {
    PublishSheet()
  }

  @Builder
  private buildBoardFlowSheet() {
    if (this.selectedPin) {
      BoardFlowSheet({
        mode: this.boardSheetMode,
        boards: this.boards,
        pin: this.selectedPin,
        newBoardName: this.newBoardName,
        feedbackMessage: this.feedbackMessage,
        onSave: (boardId: string) => this.saveToBoard(boardId),
        onCreateBoard: () => this.openNewBoardSheet(),
        onNameChange: (value: string) => this.newBoardName = value,
        onBack: () => this.returnToBoardPicker(),
        onCreate: () => this.createBoard()
      })
    }
  }

  @Builder
  private buildPinDetail() {
    if (this.selectedPin) {
      PinDetailPage({
        pin: this.selectedPin,
        relatedPins: this.relatedPinsFor(this.selectedPin),
        saved: this.isSaved(this.selectedPin.id),
        liked: this.isLiked(this.selectedPin.id),
        feedbackMessage: this.feedbackMessage,
        onBack: () => this.backFromDetail(),
        onToggleLike: () => {
          if (this.selectedPin) {
            this.toggleLike(this.selectedPin.id);
          }
        },
        onSave: () => {
          this.activeSheet = ActiveSheet.BoardPicker;
          this.feedbackMessage = '';
        },
        onMore: () => {
          this.activeSheet = ActiveSheet.PinOptions;
          this.feedbackMessage = '';
        },
        onShare: () => {
          if (this.selectedPin) {
            this.openPinShare(this.selectedPin);
          }
        },
        onOpenRelatedPins: () => this.openRelatedPins(),
        onRelatedOpen: (relatedPin: Pin) => this.openRelatedPin(relatedPin),
        onFeedback: (message: string) => this.feedbackMessage = message
      })
        .id(`pin-detail-page-${this.detailRouteKey}`)
        .transition(this.pageSettleTransition())
    }
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
  private buildRelatedPinsSheet(pin: Pin) {
    RelatedPinsSheet({
      relatedPins: this.relatedPinsFor(pin),
      onOpen: (relatedPin: Pin) => this.openRelatedPin(relatedPin)
    })
  }

  @Builder
  private buildActiveSheet() {
    if (this.activeSheet === ActiveSheet.Publish) {
      this.buildPublishSheet();
    } else if (this.activeSheet === ActiveSheet.PinOptions && this.selectedPin) {
      this.buildPinOptions(this.selectedPin);
    } else if (this.activeSheet === ActiveSheet.Share && (this.sheetPin || this.selectedPin)) {
      this.buildShareSheet(this.sheetPin ? this.sheetPin : this.selectedPin as Pin);
    } else if (this.activeSheet === ActiveSheet.BoardPicker && this.selectedPin) {
      this.buildBoardFlowSheet();
    } else if (this.activeSheet === ActiveSheet.RelatedPins && (this.sheetPin || this.selectedPin)) {
      this.buildRelatedPinsSheet(this.sheetPin ? this.sheetPin : this.selectedPin as Pin);
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
            pins: this.pins,
            resetKey: this.homeResetKey,
            onOpenPin: (pin: Pin) => this.openPin(pin),
            onSharePin: (pin: Pin) => this.openPinShare(pin)
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
        }.tabBar(this.buildTabBar('通知', 3))

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
          this.buildPinDetail()
        } else if (this.showSettings) {
          SettingsPage({
            profile: this.profile,
            onBack: () => this.closeSettings(),
            onExit: () => this.closeSettings()
          })
            .id('settings-page')
            .transition(this.pageSettleTransition())
        } else {
          this.buildRootPage()
        }

    }
    .width('100%')
    .height('100%')
    .bindSheet(this.activeSheet !== ActiveSheet.None, this.buildActiveSheet(), {
        height: this.activeSheet === ActiveSheet.RelatedPins ? SheetSize.MEDIUM : SheetSize.FIT_CONTENT,
        detents: this.activeSheet === ActiveSheet.RelatedPins ?
          [SheetSize.MEDIUM, SheetSize.LARGE] : [SheetSize.FIT_CONTENT],
        dragBar: true,
        showClose: this.activeSheet !== ActiveSheet.RelatedPins &&
          !(this.activeSheet === ActiveSheet.BoardPicker && this.boardSheetMode === BoardSheetMode.NewBoard),
        title: this.activeSheet === ActiveSheet.RelatedPins ||
          (this.activeSheet === ActiveSheet.BoardPicker && this.boardSheetMode === BoardSheetMode.NewBoard) ? undefined : {
          title: this.activeSheet === ActiveSheet.BoardPicker ? '收藏到画板' :
            (this.activeSheet === ActiveSheet.PinOptions ? '选项' :
              (this.activeSheet === ActiveSheet.Share ? '分享到' : '立即开始创作'))
        },
        preferType: this.activeSheet === ActiveSheet.RelatedPins ||
          (this.activeSheet === ActiveSheet.BoardPicker && this.boardSheetMode === BoardSheetMode.NewBoard) ?
          SheetType.BOTTOM : undefined,
        backgroundColor: Color.White,
        maskColor: this.activeSheet === ActiveSheet.Publish ? '#66000000' : '#99000000',
        onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
          if (this.activeSheet === ActiveSheet.BoardPicker && this.boardSheetMode === BoardSheetMode.NewBoard &&
            dismissSheetAction.reason === DismissReason.PRESS_BACK) {
            this.returnToBoardPicker();
            return;
          }
          dismissSheetAction.dismiss();
        },
        onDisappear: () => {
          this.closeActiveSheet();
          this.newBoardName = '';
        }
    })
  }
}
