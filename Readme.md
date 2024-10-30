
## 과제 요구사항
### ThreadSafe한 메모리 관리
 - Swift ThreadSafe한 자료구조 혹은 기술 중에는 최근에 나온 Sendable protocol을 준수하는 Sendable이 있으나
본 과제는 SDK인 관계로 고객사 최소 요구사항이 iOS 13이하일 수도 있다는 것을 가정으로 Sendable protocol을 사용하기에 부적합하다고 판단했습니다.
- Swift Concurrency가 나오기 전에 thread safe하게 만드는 방법은 다음과 같이 3가지 정도의 방법이 있습니다.
1. DispatchSemaphore, NSLock() 같은 락의 방법
2. DispatchQueue를 통한 Serial Queue 사용 방법
3. DispatchBarrier를 통한 방법

위의 3가지 방법 중 본 과제는 DispatchQueue의 SerialQueue를 사용한 Atomic 변수를 만들어서 사용했습니다.

---

### Local Rate Limit
- API를 호출할때 1초에 하나씩 보낼 수 있게 limit을 거는 방법
- 확장성 

본 요구사항은 SBNetworkSchedular라는 API Schedular를 사용하여 구현했습니다.   
SBNetworkSchedular는  DispatchSemaphore와 NSOperationQueue이용하여 인입된 network request들을 저장하였다가,
이전 request가 끝났을때 시간을 비교하여 순차적으로 다음 request를 요청하는 local rate limit의 기능을 구현했습니다.
현재는 모든 API Request에 대하여 local rate limit을 걸어놓았지만 향후 옵셔널하게 함수에 needRateLimit등의 인자를 받아서 큐에 적재할건지 아니면 바로 요청할 건지 결정할 수 있게 할 수 있습니다.
  
--- 

### Memory 기법의 확장성
- protocol을 통한 추상화 기법 적용 

--- 

### 오류처리
- SBNetworkError
- SBError

본 과제에서 Error 크게 2가지로 나누었습니다.   
네트워크 전용 error인 SBNetworkError와 앱의 전반적인 error를 담당할 SBError입니다.  

---

### TestCase

- MockUrlSession, MockUrlSessionDataTask   
네트워크 테스트를 위해서 UrlSession, UrlSessionDataTask를 상속하여 구현했습니다.   
네트워크 통신을 담당하는 SBBaseNetworkManager에 MockUrlSession을 주입하여 Mock 객체가 테스트 코드에서 실제 UrlSession을 대체 할 수 있게 구현했습니다.
 
- 참고사항   
테스트 케이스 중 testRateLimitCreateUser()의 경우 과제 요구서를 보았을때, 
userManager.createUsers() 한해서 한번에 최대 10명까지만 API를 통해서 생성이 가능하다고 판단했습니다.   
따라서 테스트 케이스를 수정하여 진행하였습니다. 

