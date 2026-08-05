import localUnitTest from './LocalUnit.test';
import inspirationRepositoryTest from './InspirationRepository.test';
import legalDocumentTest from './LegalDocument.test';

export default function testsuite() {
  localUnitTest();
  inspirationRepositoryTest();
  legalDocumentTest();
}
