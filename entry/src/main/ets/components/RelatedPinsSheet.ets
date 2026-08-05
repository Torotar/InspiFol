import { mediaquery } from '@kit.ArkUI';
import { Pin } from '../models/InspirationModels';
import { PinArtwork } from './PinArtwork';

@Component
export struct RelatedPinsSheet {
  @Prop relatedPins: Pin[] = [];
  onOpen?: (pin: Pin) => void;
  private scroller: Scroller = new Scroller();
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

  @Builder
  private relatedGrid() {
    WaterFlow({
      scroller: this.scroller,
      // Keep every local card laid out so sheet resizing reveals content in the same frame.
      layoutMode: WaterFlowLayoutMode.ALWAYS_TOP_DOWN
    }) {
      ForEach(this.relatedPins, (relatedPin: Pin) => {
        FlowItem() {
          this.relatedCard(relatedPin)
        }
        .width('100%')
      }, (relatedPin: Pin) => relatedPin.id)
    }
    .columnsTemplate(this.isTablet ? '1fr 1fr 1fr' : '1fr 1fr')
    .columnsGap(this.isTablet ? 16 : 12)
    .rowsGap(18)
    .padding({ left: 16, right: 16, top: 24, bottom: 32 })
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  private relatedCard(pin: Pin) {
    Column({ space: 8 }) {
      PinArtwork({ pin: pin, compact: true })
        .width('100%')
      Text(pin.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#202124')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.onOpen !== undefined) {
        this.onOpen(pin);
      }
    })
    .accessibilityText(`打开相关灵感：${pin.title}`)
  }

  build() {
    Column() {
      this.relatedGrid()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}
