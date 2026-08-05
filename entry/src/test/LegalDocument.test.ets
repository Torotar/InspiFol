import { describe, it, expect } from '@ohos/hypium';
import { ExternalLinkService, LegalDocument } from '../main/ets/services/ExternalLinkService';

export default function legalDocumentTest() {
  describe('Legal document links', () => {
    it('keeps official legal document URLs', 0, () => {
      expect(ExternalLinkService.urlFor(LegalDocument.Terms))
        .assertEqual('https://policy.pinterest.com/en/terms-of-service');
      expect(ExternalLinkService.urlFor(LegalDocument.Privacy))
        .assertEqual('https://policy.pinterest.com/en/privacy-policy');
    });
  });
}
