@Component
export struct PublishSheet {
  @State private feedbackMessage: string = '';

  aboutToAppear(): void {
    this.feedbackMessage = '';
  }

  private showUnavailableFeedback(label: string): void {
    this.feedbackMessage = `${label}功能暂未开放`;
  }

  @Builder
  private buildOption(label: string, iconName: string) {
    Column({ space: 8 }) {
      Button({ type: ButtonType.Normal }) {
        Image($r(iconName))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Contain)
      }
      .width(76)
      .height(76)
      .backgroundColor('#E7E7E3')
      .borderRadius(22)
      .onClick(() => this.showUnavailableFeedback(label))
      .accessibilityText(label)
      .accessibilityDescription(`${label}功能暂未开放`)

      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column({ space: 22 }) {
      Row({ space: 18 }) {
        this.buildOption('Pin 图', 'app.media.lucide_pin')
        this.buildOption('拼贴', 'app.media.lucide_scissors')
        this.buildOption('图板', 'app.media.lucide_layout_grid')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (this.feedbackMessage.length > 0) {
        Text(this.feedbackMessage)
          .fontSize(13)
          .fontColor('#70757A')
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 8, bottom: 28 })
    .backgroundColor(Color.White)
  }
}
