import { Pin } from '../models/InspirationModels';
import { PinCard } from './PinCard';
import { mediaquery } from '@kit.ArkUI';

@Component
export struct PinFlow {
  @Prop pins: Pin[] = [];
  @Prop emptyTitle: string = '没有找到相关灵感';
  @Prop emptySubtitle: string = '换一个关键词，或回到首页看看。';
  onOpen?: (pin: Pin) => void;
  onShare?: (pin: Pin) => void;
  scroller: Scroller = new Scroller();
  @State private isTablet: boolean = false;
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

  build() {
    if (this.pins.length === 0) {
      Column({ space: 10 }) {
        Text(this.emptyTitle).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#202124')
        Text(this.emptySubtitle).fontSize(14).fontColor('#70757A')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      WaterFlow({ scroller: this.scroller }) {
        ForEach(this.pins, (pin: Pin) => {
          FlowItem() {
            PinCard({ pin: pin, onOpen: this.onOpen, onShare: this.onShare })
          }
          .width('100%')
        }, (pin: Pin) => pin.id)
      }
      .columnsTemplate(this.isTablet ? '1fr 1fr 1fr' : '1fr 1fr')
      .columnsGap(this.isTablet ? 16 : 12)
      .rowsGap(18)
      .padding({ left: 16, right: 16, bottom: 0 })
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
