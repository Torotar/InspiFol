import { Pin } from '../models/InspirationModels';
import { PinArtwork } from '../components/PinArtwork';
import { mediaquery } from '@kit.ArkUI';
import { HdsNavDestination, HdsNavDestinationTitleMode } from '@kit.UIDesignKit';

@Component
export struct PinDetailPage {
  @Prop @Watch('onPinChanged') pin: Pin = {} as Pin;
  @Prop relatedPins: Pin[] = [];
  @Prop saved: boolean = false;
  @Prop liked: boolean = false;
  @Prop feedbackMessage: string = '';
  @State private descriptionExpanded: boolean = false;
  @State private isTablet: boolean = false;
  onBack?: () => void;
  onToggleLike?: () => void;
  onSave?: () => void;
  onMore?: () => void;
  onShare?: () => void;
  onOpenRelatedPins?: () => void;
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
  private actionButton(iconName: string, label: string, count: number | undefined, action?: () => void) {
    Row({ space: 2 }) {
      Button({ type: ButtonType.Circle }) {
        Image($r(iconName))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
      .width(44)
      .height(44)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (action !== undefined) {
          action();
        }
      })
      .accessibilityText(count !== undefined && count > 0 ? `${label}，${count}` : label)

      if (count !== undefined && count > 0) {
        Text(this.formatEngagementCount(count))
          .fontSize(13)
          .fontColor('#202124')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .alignItems(VerticalAlign.Center)
  }

  private formatEngagementCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return `${count}`;
  }

  @Builder
  private relatedCard(pin: Pin) {
    Button({ type: ButtonType.Normal }) {
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
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(0)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      if (this.onRelatedOpen !== undefined) {
        this.onRelatedOpen(pin);
      }
    })
    .accessibilityText(`打开灵感：${pin.title}`)
  }

  private relatedPinsForColumn(columnIndex: number, columnCount: number): Pin[] {
    return this.relatedPins.filter((_pin: Pin, index: number): boolean => index % columnCount === columnIndex);
  }

  @Builder
  private relatedColumn(columnIndex: number, columnCount: number) {
    Column({ space: 18 }) {
      ForEach(this.relatedPinsForColumn(columnIndex, columnCount), (pin: Pin) => {
        this.relatedCard(pin)
      }, (pin: Pin) => pin.id)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
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
                .onClick(() => {
                  if (this.onOpenRelatedPins !== undefined) {
                    this.onOpenRelatedPins();
                  }
                })
                .accessibilityText('查看相关灵感')
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
            Row({ space: 6 }) {
              this.actionButton(
                this.liked ? 'app.media.lucide_heart_filled' : 'app.media.lucide_heart',
                this.liked ? '取消点赞' : '点赞',
                this.pin.likeCount !== undefined ? this.pin.likeCount + (this.liked ? 1 : 0) : undefined,
                () => {
                  if (this.onToggleLike !== undefined) {
                    this.onToggleLike();
                  }
                }
              )
              this.actionButton('app.media.lucide_message_circle', '评论', this.pin.commentCount, () =>
                this.showFeedback('评论功能暂不可用'))
              this.actionButton('app.media.lucide_share_2', '分享', undefined, () => {
                if (this.onShare !== undefined) {
                  this.onShare();
                }
              })
              this.actionButton('app.media.lucide_ellipsis', '更多操作', undefined, () => {
                if (this.onMore !== undefined) {
                  this.onMore();
                }
              })
            }
            .alignItems(VerticalAlign.Center)
            Blank()
            Button(this.saved ? '已收藏' : '收藏')
              .width(80)
              .height(44)
              .backgroundColor('#E60023')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(22)
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

          Row({ space: this.isTablet ? 16 : 12 }) {
            if (this.isTablet) {
              this.relatedColumn(0, 3)
              this.relatedColumn(1, 3)
              this.relatedColumn(2, 3)
            } else {
              this.relatedColumn(0, 2)
              this.relatedColumn(1, 2)
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        .padding({ left: 18, right: 18, top: 0, bottom: 42 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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
