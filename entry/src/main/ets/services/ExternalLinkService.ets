import { Want, common } from '@kit.AbilityKit';

export enum LegalDocument {
  Terms = 'terms',
  Privacy = 'privacy'
}

export class ExternalLinkService {
  static readonly TERMS_URL: string = 'https://policy.pinterest.com/en/terms-of-service';
  static readonly PRIVACY_URL: string = 'https://policy.pinterest.com/en/privacy-policy';

  static urlFor(document: LegalDocument): string {
    return document === LegalDocument.Terms ? ExternalLinkService.TERMS_URL : ExternalLinkService.PRIVACY_URL;
  }

  static async openLegalDocument(
    context: common.UIAbilityContext,
    document: LegalDocument
  ): Promise<boolean> {
    const want: Want = {
      action: 'ohos.want.action.viewData',
      uri: ExternalLinkService.urlFor(document),
      entities: ['entity.system.browsable']
    };
    try {
      await context.startAbility(want);
      return true;
    } catch (_error) {
      return false;
    }
  }
}
