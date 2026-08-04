import { Pin } from '../models/InspirationModels';

@Component
export struct PinArtwork {
  @Prop pin: Pin = {} as Pin;
  @Prop compact: boolean = false;

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.pin.backgroundColor)
      Text(this.pin.artworkSymbol)
        .fontSize(this.compact ? 74 : 132)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.pin.accentColor)
        .margin({ left: this.compact ? 16 : 28, bottom: this.compact ? 26 : 42 })
        .opacity(0.88)
      Text(this.pin.artworkLabel)
        .fontSize(this.compact ? 10 : 12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.pin.accentColor)
        .letterSpacing(1.2)
        .margin({ left: this.compact ? 16 : 28, bottom: this.compact ? 12 : 18 })
    }
    .width('100%')
    .height(this.compact ? this.pin.artworkHeight : this.pin.artworkHeight + 110)
    .borderRadius(18)
    .clip(true)
  }
}
