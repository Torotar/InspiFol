import { Pin } from '../models/InspirationModels';
import { PinArtwork } from '../components/PinArtwork';
import { mediaquery } from '@kit.ArkUI';
import { HdsNavDestination, HdsNavDestinationTitleMode } from '@kit.UIDesignKit';

@Component
export struct PinDetailPage {
  @Prop @Watch('onPinChanged') pin: Pin = {} as Pin;
  @Prop relatedPins: Pin[] = [];
  @Prop saved: boolean = false;
  @Prop feedbackMessage: string = '';
  @State private descriptionExpanded: boolean = false;
  @State private isTablet: boolean = false;
  @State private liked: boolean = false;
  onBack?: () => void;
  onSave?: () => void;
  onMore?: () => void;
  onShare?: () => void;
  onRelatedOpen?: (pin: Pin) => void;
  onFeedback?: (message: string) => void;
  private tabletListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(width >= 600vp)');

  aboutToAppear(): void {
    this.isTablet = this.tabletListener.matches;
    this.tabletListener.on('change', (result: mediaquery.MediaQueryResult) => {
      this.isTablet = result.matches;
    });
  }

  aboutToDisappear(): void {
    this.tabletListener.off('change');
  }

  onPinChanged(): void {
    this.liked = false;
    this.descriptionExpanded = false;
  }

  private showFeedback(message: string): void {
    if (this.onFeedback !== undefined) {
      this.onFeedback(message);
    }
  }

  private shouldShowDescriptionToggle(): boolean {
    const oneLineCharacterLimit = this.isTablet ? 38 : 22;
    return this.pin.description.trim().length > oneLineCharacterLimit;
  }

  @Builder
  private actionButton(iconName: string, label: string, action?: () => void) {
    Button({ type: ButtonType.Circle }) {
      Image($r(iconName))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
    }
    .width(48)
    .height(48)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      if (action !== undefined) {
        action();
      }
    })
    .accessibilityText(label)
  }

  @Builder
  private relatedCard(pin: Pin) {
    Column({ space: 8 }) {
      PinArtwork({ pin: pin, compact: true })
      Text(pin.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#202124')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('48%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.onRelatedOpen !== undefined) {
        this.onRelatedOpen(pin);
      }
    })
    .accessibilityText(`打开灵感：${pin.title}`)
  }

  build() {
    HdsNavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          Stack({ alignContent: Alignment.TopStart }) {
            PinArtwork({ pin: this.pin })
            Column() {
              Blank()
              Row() {
                Blank()
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.lucide_scan_search'))
                    .width(26)
                    .height(26)
                }
                .width(48)
                .height(48)
                .backgroundColor('rgba(255, 255, 255, 0.72)')
                .onClick(() => this.showFeedback('相关照片搜索功能暂不可用'))
                .accessibilityText('搜索相关照片')
              }
              .width('100%')
            }
            .width('100%')
            .height('100%')
            .padding(10)
          }
          .width('100%')
          .height(this.pin.artworkHeight + 110)
          .borderRadius(18)
          .clip(true)

          Row() {
            Row({ space: 10 }) {
              this.actionButton(
                this.liked ? 'app.media.lucide_heart_filled' : 'app.media.lucide_heart',
                this.liked ? '取消点赞' : '点赞',
                () => this.liked = !this.liked
              )
              this.actionButton('app.media.lucide_message_circle', '评论', () =>
                this.showFeedback('评论功能暂不可用'))
              this.actionButton('app.media.lucide_share_2', '分享', () => {
                if (this.onShare !== undefined) {
                  this.onShare();
                }
              })
              this.actionButton('app.media.lucide_ellipsis', '更多操作', () => {
                if (this.onMore !== undefined) {
                  this.onMore();
                }
              })
            }
            .alignItems(VerticalAlign.Center)
            Blank()
            Button(this.saved ? '已收藏' : '收藏')
              .width(96)
              .height(48)
              .backgroundColor('#E60023')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(24)
              .onClick(() => {
                if (this.onSave !== undefined) {
                  this.onSave();
                }
              })
              .accessibilityText(this.saved ? '已收藏' : '收藏')
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Column({ space: 10 }) {
            Row({ space: 10 }) {
              Text('●')
                .fontSize(24)
                .fontColor('#1769E0')
              Text(this.pin.creator)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#202124')
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Text(this.pin.title)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#202124')
              .width('100%')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row({ space: 8 }) {
              Text(this.pin.description)
                .fontSize(16)
                .lineHeight(24)
                .fontColor('#202124')
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(this.descriptionExpanded ? 20 : 1)
              if (this.shouldShowDescriptionToggle() || this.descriptionExpanded) {
                Text(this.descriptionExpanded ? '折叠' : '查看更多')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#202124')
                  .onClick(() => this.descriptionExpanded = !this.descriptionExpanded)
                  .accessibilityText(this.descriptionExpanded ? '折叠简介' : '展开简介')
              }
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom)

            if (this.pin.websiteUrl !== undefined && this.pin.websiteUrl.trim().length > 0) {
              Button('访问网站')
                .width('100%')
                .height(50)
                .backgroundColor('#E8E8E3')
                .fontColor('#202124')
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .borderRadius(25)
                .onClick(() => this.showFeedback('网站访问功能暂不可用'))
                .accessibilityText('访问网站')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.feedbackMessage.length > 0) {
            Text(this.feedbackMessage)
              .fontSize(14)
              .fontColor('#0D652D')
              .padding(14)
              .backgroundColor('#E6F4EA')
              .borderRadius(12)
              .width('100%')
          }

          Text('更多探索内容')
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor('#202124')
            .width('100%')
            .margin({ top: 4 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.relatedPins, (pin: Pin) => {
              this.relatedCard(pin)
            }, (pin: Pin) => pin.id)
          }
          .width('100%')
        }
        .padding({ left: 18, right: 18, top: 0, bottom: 42 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .titleBar({
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: true,
      content: {
        title: {
          mainTitle: ''
        },
        backIcon: {
          isEnabled: true,
          action: () => {
            if (this.onBack !== undefined) {
              this.onBack();
            }
          }
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MINI)
    .hideBackButton(false)
    .onBackPressed(() => {
      if (this.onBack !== undefined) {
        this.onBack();
      }
      return true;
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
    .backgroundColor(Color.White)
  }
}
