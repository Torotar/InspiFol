import { Board, Pin } from '../models/InspirationModels';
import { BoardPicker } from './BoardPicker';
import { NewBoardSheet } from './NewBoardDialog';

@Component
export struct BoardFlowSheet {
  @Prop mode: string = 'picker';
  @Prop boards: Board[] = [];
  @Prop pin: Pin = {} as Pin;
  @Prop newBoardName: string = '';
  @Prop feedbackMessage: string = '';
  onSave?: (boardId: string) => void;
  onCreateBoard?: () => void;
  onNameChange?: (value: string) => void;
  onBack?: () => void;
  onCreate?: () => void;

  build() {
    if (this.mode === 'new-board') {
      NewBoardSheet({
        pin: this.pin,
        newBoardName: this.newBoardName,
        feedbackMessage: this.feedbackMessage,
        onNameChange: (value: string) => {
          if (this.onNameChange !== undefined) {
            this.onNameChange(value);
          }
        },
        onBack: () => {
          if (this.onBack !== undefined) {
            this.onBack();
          }
        },
        onCreate: () => {
          if (this.onCreate !== undefined) {
            this.onCreate();
          }
        }
      })
    } else {
      BoardPicker({
        boards: this.boards,
        onSave: (boardId: string) => {
          if (this.onSave !== undefined) {
            this.onSave(boardId);
          }
        },
        onCreateBoard: () => {
          if (this.onCreateBoard !== undefined) {
            this.onCreateBoard();
          }
        }
      })
    }
  }
}
