import localUnitTest from './LocalUnit.test';
import inspirationRepositoryTest from './InspirationRepository.test';

export default function testsuite() {
  localUnitTest();
  inspirationRepositoryTest();
}
