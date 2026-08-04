import common from '@ohos.app.ability.common';
import dataPreferences from '@ohos.data.preferences';
import { Board, LocalBoardState } from '../models/InspirationModels';

const STORE_NAME = 'inspira_boards';
const BOARDS_KEY = 'boards';
const SAVED_PINS_KEY = 'saved_pin_ids';

export class BoardStorageService {
  static async load(context: common.UIAbilityContext): Promise<LocalBoardState> {
    try {
      const preferences = await dataPreferences.getPreferences(context, STORE_NAME);
      const boardsJson = preferences.getSync(BOARDS_KEY, '[]') as string;
      const savedJson = preferences.getSync(SAVED_PINS_KEY, '[]') as string;
      return { boards: JSON.parse(boardsJson) as Board[], savedPinIds: JSON.parse(savedJson) as string[] };
    } catch (_) {
      return { boards: [], savedPinIds: [] };
    }
  }

  static async save(context: common.UIAbilityContext, state: LocalBoardState): Promise<boolean> {
    try {
      const preferences = await dataPreferences.getPreferences(context, STORE_NAME);
      preferences.putSync(BOARDS_KEY, JSON.stringify(state.boards));
      preferences.putSync(SAVED_PINS_KEY, JSON.stringify(state.savedPinIds));
      await preferences.flush();
      return true;
    } catch (_) {
      return false;
    }
  }
}
