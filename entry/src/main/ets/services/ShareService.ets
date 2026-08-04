import { Want, common } from '@kit.AbilityKit';
import { Pin } from '../models/InspirationModels';

export class ShareService {
  static async sharePin(context: common.UIAbilityContext, pin: Pin): Promise<boolean> {
    const content = `${pin.title}\n来自 ${pin.creator}\n${pin.description}`;
    const want: Want = {
      action: 'ohos.want.action.sendData',
      type: 'text/plain',
      parameters: {
        'ohos.want.param.text': content
      }
    };
    try {
      await context.startAbility(want);
      return true;
    } catch (_error) {
      return false;
    }
  }
}
