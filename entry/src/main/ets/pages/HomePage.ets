import { Pin, RecommendationChip, RecommendationStatus } from '../models/InspirationModels';
import { PinFlow } from '../components/PinFlow';
import { Chip, ChipSize } from '@kit.ArkUI';

@Component
export struct HomePage {
  @Prop pins: Pin[] = [];
  @Prop recommendations: RecommendationChip[] = [];
  @Prop recommendationStatus: RecommendationStatus = RecommendationStatus.Loading;
  @Prop selectedRecommendationId: string = 'demo-for-you';
  @Prop @Watch('onResetKeyChanged') resetKey: number = 0;
  onOpenPin?: (pin: Pin) => void;
  onSharePin?: (pin: Pin) => void;
  onRecommendationClick?: (item: RecommendationChip) => void;
  scroller: Scroller = new Scroller();

  private resetToTop(): void {
    this.scroller.scrollToIndex(0, false);
  }

  onResetKeyChanged(): void {
    this.resetToTop();
  }

  build() {
    Column({ space: 12 }) {
      if (this.recommendationStatus === RecommendationStatus.Ready && this.recommendations.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.recommendations, (item: RecommendationChip) => {
              Chip({
                label: { text: item.label, fontSize: 14 },
                size: ChipSize.NORMAL,
                allowClose: false,
                activated: this.selectedRecommendationId === item.id,
                backgroundColor: '#F1F3F4',
                activatedBackgroundColor: '#E60023',
                borderRadius: 18,
                onClicked: () => {
                  if (this.onRecommendationClick !== undefined) {
                    this.onRecommendationClick(item);
                  }
                },
                accessibilityDescription: item.query.length === 0 ?
                  '在首页显示全部推荐内容' : `在首页显示${item.label}内容`
              })
            }, (item: RecommendationChip) => item.id)
          }
          .padding({ left: 24, right: 24 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(48)
      } else if (this.recommendationStatus === RecommendationStatus.Loading) {
        Text('正在准备推荐内容')
          .fontSize(13)
          .fontColor('#70757A')
          .margin({ left: 20, right: 20 })
      } else if (this.recommendationStatus === RecommendationStatus.Empty) {
        Text('暂无推荐内容')
          .fontSize(13)
          .fontColor('#70757A')
          .margin({ left: 20, right: 20 })
      } else if (this.recommendationStatus === RecommendationStatus.Error) {
        Text('推荐暂不可用，以下为全部本地灵感')
          .fontSize(13)
          .fontColor('#70757A')
          .margin({ left: 20, right: 20 })
      }
      PinFlow({
        pins: this.pins,
        onOpen: this.onOpenPin,
        onShare: this.onSharePin,
        scroller: this.scroller
      })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 56 })
  }

}
