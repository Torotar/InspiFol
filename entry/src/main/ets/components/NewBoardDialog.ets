@Component
export struct NewBoardDialog {
  @Prop newBoardName: string = '';
  @Prop feedbackMessage: string = '';
  onNameChange?: (value: string) => void;
  onClose?: () => void;
  onCreate?: () => void;

  build() {
    Column({ space: 16 }) {
      Text('新建画板').fontSize(20).fontWeight(FontWeight.Bold)
      TextInput({ text: this.newBoardName, placeholder: '例如：周末旅行' })
        .width('100%')
        .height(48)
        .backgroundColor('#F1F3F4')
        .borderRadius(12)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          if (this.onNameChange !== undefined) {
            this.onNameChange(value);
          }
        })
      if (this.feedbackMessage.length > 0) {
        Text(this.feedbackMessage).fontSize(13).fontColor('#B3261E')
      }
      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(46)
          .backgroundColor('#F1F3F4')
          .fontColor('#202124')
          .borderRadius(12)
          .onClick(() => {
            if (this.onClose !== undefined) {
              this.onClose();
            }
          })
        Button('创建')
          .layoutWeight(1)
          .height(46)
          .backgroundColor('#E60023')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            if (this.onCreate !== undefined) {
              this.onCreate();
            }
          })
      }
      .width('100%')
    }
    .width('86%')
    .padding(22)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
