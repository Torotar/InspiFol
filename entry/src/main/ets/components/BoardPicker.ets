import { Board } from '../models/InspirationModels';

@Component
export struct BoardPicker {
  @Prop boards: Board[] = [];
  onClose?: () => void;
  onSave?: (boardId: string) => void;
  onCreateBoard?: () => void;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('收藏到画板').fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('×').fontSize(22).fontColor('#202124')
        }
        .width(36)
        .height(36)
        .backgroundColor('#F1F3F4')
        .onClick(() => {
          if (this.onClose !== undefined) {
            this.onClose();
          }
        })
        .accessibilityText('关闭')
      }
      .width('100%')
      if (this.boards.length === 0) {
        Text('先创建一个画板来保存这条灵感。').fontSize(14).fontColor('#70757A').margin({ top: 8 })
      } else {
        ForEach(this.boards, (board: Board) => {
          Button(board.name)
            .width('100%')
            .height(48)
            .backgroundColor('#F1F3F4')
            .fontColor('#202124')
            .borderRadius(12)
            .onClick(() => {
              if (this.onSave !== undefined) {
                this.onSave(board.id);
              }
            })
        }, (board: Board) => board.id)
      }
      Button('+ 新建画板')
        .width('100%')
        .height(48)
        .backgroundColor('#202124')
        .fontColor(Color.White)
        .borderRadius(12)
        .onClick(() => {
          if (this.onCreateBoard !== undefined) {
            this.onCreateBoard();
          }
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}
