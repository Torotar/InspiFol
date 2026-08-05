import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { Pin } from '../models/InspirationModels';
import { PinArtwork } from './PinArtwork';

@Component
export struct NewBoardSheet {
  @Prop pin: Pin = {} as Pin;
  @Prop newBoardName: string = '';
  @Prop feedbackMessage: string = '';
  onNameChange?: (value: string) => void;
  onBack?: () => void;
  onCreate?: () => void;

  @Builder
  private buildCreateButton() {
    Button('创建')
      .id('new-board-submit')
      .width(72)
      .height(36)
      .backgroundColor('#E60023')
      .fontColor(Color.White)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .borderRadius(18)
      .onClick(() => {
        if (this.onCreate !== undefined) {
          this.onCreate();
        }
      })
      .accessibilityText('创建画板')
  }

  build() {
    HdsNavigation() {
      Scroll() {
        Column({ space: 20 }) {
          Row({ space: 12 }) {
            PinArtwork({ pin: this.pin, compact: true })
              .width(88)
              .height(104)

            Column({ space: 6 }) {
              Text('当前灵感')
                .fontSize(13)
                .fontColor('#70757A')
              Text(this.pin.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#202124')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`来自 ${this.pin.creator}`)
                .fontSize(13)
                .fontColor('#70757A')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Column({ space: 8 }) {
            Text('画板名称')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#202124')
            TextInput({ text: this.newBoardName, placeholder: '例如：周末旅行' })
              .id('new-board-name-input')
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
              Text(this.feedbackMessage)
                .fontSize(13)
                .fontColor('#B3261E')
            }
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('画板设置')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#202124')
            Row({ space: 12 }) {
              Column({ space: 3 }) {
                Text('私密画板')
                  .fontSize(15)
                  .fontColor('#202124')
                Text('创建的画板仅保存在本机。')
                  .fontSize(13)
                  .fontColor('#70757A')
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text('仅自己可见')
                .fontSize(12)
                .fontColor('#70757A')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('#F1F3F4')
                .borderRadius(10)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FAFAFA')
            .borderRadius(14)

            Row({ space: 12 }) {
              Column({ space: 3 }) {
                Text('群组画板')
                  .fontSize(15)
                  .fontColor('#202124')
                Text('暂不可用：群组和协作服务尚未接入。')
                  .fontSize(13)
                  .fontColor('#70757A')
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text('暂不可用')
                .fontSize(12)
                .fontColor('#70757A')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('#F1F3F4')
                .borderRadius(10)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FAFAFA')
            .borderRadius(14)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 24 })
      }
      .width('100%')
      .height(424)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .titleBar({
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: true,
      content: {
        title: {
          mainTitle: '新建画板'
        },
        backIcon: {
          isEnabled: true,
          action: () => {
            if (this.onBack !== undefined) {
              this.onBack();
            }
          }
        },
        stackBuilder: () => {
          this.buildCreateButton()
        }
      }
    })
    .titleMode(HdsNavigationTitleMode.MINI)
    .hideBackButton(false)
    .backgroundColor(Color.White)
    .width('100%')
    .height(480)
    .id('new-board-sheet')
  }
}
