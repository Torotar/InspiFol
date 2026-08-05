import { Pin } from '../models/InspirationModels';
import { PinFlow } from '../components/PinFlow';

@Component
export struct HomePage {
  @Prop pins: Pin[] = [];
  @Prop @Watch('onResetKeyChanged') resetKey: number = 0;
  onOpenPin?: (pin: Pin) => void;
  onSharePin?: (pin: Pin) => void;
  scroller: Scroller = new Scroller();

  private resetToTop(): void {
    this.scroller.scrollToIndex(0, false);
  }

  onResetKeyChanged(): void {
    this.resetToTop();
  }

  build() {
    Column() {
      PinFlow({
        pins: this.pins,
        emptyTitle: '还没有内容',
        emptySubtitle: '内容发布后会显示在这里',
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
