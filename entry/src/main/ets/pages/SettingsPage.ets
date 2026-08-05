import { HdsNavDestination, HdsNavDestinationTitleMode, HdsNavigation } from '@kit.UIDesignKit';
import { Profile } from '../models/InspirationModels';

@Component
export struct SettingsPage {
  @Prop profile: Profile = {
    displayName: '',
    handle: '',
    avatarInitial: '',
    followerCount: 0,
    followingCount: 0
  };
  onBack?: () => void;
  onExit?: () => void;
  @State private showExitConfirm: boolean = false;
  private readonly settingsScroller: Scroller = new Scroller();
  private readonly settingsPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.settingsPathStack.pushPath({ name: 'settings' });
  }

  private goBack(): void {
    if (this.onBack !== undefined) {
      this.onBack();
    }
  }

  private confirmExit(): void {
    this.showExitConfirm = false;
    if (this.onExit !== undefined) {
      this.onExit();
    }
  }

  @Builder
  private buildAccountRow() {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor('#6072C8')
        if (this.profile.avatarUrl !== undefined && this.profile.avatarUrl.length > 0) {
          Image(this.profile.avatarUrl)
            .width(56)
            .height(56)
            .borderRadius(28)
            .objectFit(ImageFit.Cover)
        } else {
          Text(this.profile.avatarInitial)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
      }
      .width(56)
      .height(56)
      Column({ space: 4 }) {
        Text(this.profile.displayName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Text(this.profile.handle)
          .fontSize(14)
          .fontColor('#70757A')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor('#F5F5F2')
    .borderRadius(18)
    .accessibilityGroup(true)
    .accessibilityText(`${this.profile.displayName}，${this.profile.handle}`)
  }

  @Builder
  private buildExitRow() {
    Button() {
      Row() {
        Image($r('app.media.lucide_log_out'))
          .width(23)
          .height(23)
        Text($r('app.string.settings_exit'))
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D70018')
          .margin({ left: 12 })
        Blank()
        Image($r('app.media.lucide_chevron_right'))
          .width(20)
          .height(20)
      }
      .width('100%')
      .padding({ left: 18, right: 18 })
    }
    .width('100%')
    .height(58)
    .backgroundColor(Color.Transparent)
    .onClick(() => this.showExitConfirm = true)
    .accessibilityText($r('app.string.settings_exit'))
  }

  @Builder
  private buildExitDialog() {
    Column() {
      Column({ space: 14 }) {
        Text($r('app.string.settings_exit_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Text($r('app.string.settings_exit_message'))
          .fontSize(15)
          .lineHeight(22)
          .fontColor('#5F6368')
          .textAlign(TextAlign.Center)
          .width('100%')
        Row({ space: 12 }) {
          Button($r('app.string.settings_cancel'))
            .layoutWeight(1)
            .height(46)
            .fontColor('#202124')
            .backgroundColor('#ECEFF1')
            .borderRadius(23)
            .onClick(() => this.showExitConfirm = false)
          Button($r('app.string.settings_confirm'))
            .layoutWeight(1)
            .height(46)
            .fontColor(Color.White)
            .backgroundColor('#D70018')
            .borderRadius(23)
            .onClick(() => this.confirmExit())
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(24)
      .constraintSize({ maxWidth: 420 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.38)')
  }

  @Builder
  private buildSettingsContent() {
    Column({ space: 24 }) {
      Column({ space: 10 }) {
        Text($r('app.string.settings_account_section'))
          .fontSize(14)
          .fontColor('#70757A')
          .fontWeight(FontWeight.Medium)
          .width('100%')
        this.buildAccountRow()
      }
      .width('100%')
      Column({ space: 10 }) {
        Text($r('app.string.settings_other_section'))
          .fontSize(14)
          .fontColor('#70757A')
          .fontWeight(FontWeight.Medium)
          .width('100%')
        Column() {
          this.buildExitRow()
        }
        .width('100%')
        .backgroundColor('#F5F5F2')
        .borderRadius(18)
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 12 })
  }

  @Builder
  private buildSettingsDestination(_name: string, _param: Object) {
    HdsNavDestination() {
      List({ scroller: this.settingsScroller }) {
        ListItem() {
          this.buildSettingsContent()
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 0, bottom: 32 })
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .titleBar({
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: true,
      content: {
        title: {
          mainTitle: $r('app.string.settings_title')
        },
        backIcon: {
          isEnabled: true,
          action: () => this.goBack()
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MINI)
    .hideBackButton(false)
    .onBackPressed(() => {
      if (this.showExitConfirm) {
        this.showExitConfirm = false;
      } else {
        this.goBack();
      }
      return true;
    })
    .bindToScrollable([this.settingsScroller])
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
    .backgroundColor(Color.White)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      HdsNavigation(this.settingsPathStack) {
        Column()
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true)
      .navDestination(this.buildSettingsDestination)
      .backgroundColor(Color.White)

      if (this.showExitConfirm) {
        this.buildExitDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
