# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            kr
LanguageCharset                         euc-kr


# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   적용
On                                      사용 중
Off                                     사용않는 중
TurnOn                                  사     용
TurnOff                                 사용 안함
Add                                     추가
Remove                                  제거
Previous                                이전
Next                                    다음
From                                    발신자
Subject                                 제목 
Classification                          분류
Reclassify                              재분류
Undo                                    취소
Close                                   닫기
Find                                    찾기
Filter                                  걸러냄
Yes                                     예
No                                      아니오
ChangeToYes                             '예'로 바꿈
ChangeToNo                              '아니오'로 바꿈
Bucket                                  버킷
Magnet                                  자석
Delete                                  삭제
Create                                  생성
To                                      수신자
Total                                   전체
Rename                                  이름바꾸기
Frequency                               빈도
Probability                             확률
Score                                   점수
Lookup                                  검색

# The header and footer that appear on every UI page
Header_Title                            팝파일 제어 센터
Header_Shutdown                         팝파일 종료
Header_History                          히스토리
Header_Buckets                          버킷
Header_Configuration                    설정
Header_Advanced                         고급
Header_Security                         보안
Header_Magnets                          자석

Footer_HomePage                         팝파일 홈페이지
Footer_Manual                           설명서
Footer_Forums                           게시판
Footer_FeedMe                           기부
Footer_RequestFeature                   기능요청
Footer_MailingList                      메일링 리스트

Configuration_Error1                    구분글자는 반드시 1글자여야 합니다.
Configuration_Error2                    사용자 인터페이스의 포트는 반드시 1부터 65535 사이의 숫자여야 합니다.
Configuration_Error3                    POP3 포트는 반드시 1부터 65535 사이의 숫자여야 합니다.
Configuration_Error4                    페이지 크기는 반드시 1부터 1000 사이의 숫자여야 합니다.
Configuration_Error5                    히스토리의 보존 기간은 반드시 1부터 366 사이의 숫자여야 합니다. 
Configuration_Error6                    TCP 타임아웃은 반드시 10부터 300 사이의 숫자여야 합니다. The TCP timeout must be a number between 10 and 300
Configuration_POP3Port                  POP3 포트
Configuration_POP3Update                %s로 포트를 변경했습니다. 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_Separator                 구분글자
Configuration_SepUpdate                 구분글자를 %s로 변경했습니다.
Configuration_UI                        사용자 인터페이스 웹 포트
Configuration_UIUpdate                  사용자 인터페이스 웹 포트를 %s로 변경했습니다. 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_History                   페이지당 이메일 갯수
Configuration_HistoryUpdate             페이지당 이메일 갯수를 %s로 변경했습니다.
Configuration_Days                      히스토리에 남겨둘 기간(일)
Configuration_DaysUpdate                히스토리에 남겨둘 기간(일)을 %s로 변경했습니다.
Configuration_UserInterface             사용자 인터페이스
Configuration_Skins                     스킨
Configuration_SkinsChoose               스킨 선택
Configuration_Language                  언어
Configuration_LanguageChoose            언어 선택
Configuration_ListenPorts               리슨 포트
Configuration_HistoryView               히스토리 보기
Configuration_TCPTimeout                TCP 컨넥션 타임아웃
Configuration_TCPTimeoutSecs            TCP 컨넥션 타임아웃(초)
Configuration_TCPTimeoutUpdate          TCP 컨넥션 타임아웃을 %s로 변경하였습니다.
Configuration_ClassificationInsertion   이메일 문자열 삽입
Configuration_SubjectLine               제목 바꿈
Configuration_XTCInsertion              X-Text-Classification 헤더
Configuration_XPLInsertion              X-POPFile-Link 헤더
Configuration_Logging                   로깅
Configuration_None                      없음
Configuration_ToScreen                  화면으로
Configuration_ToFile                    파일로
Configuration_ToScreenFile              화면과 파일로
Configuration_LoggerOutput              로그 출력
Configuration_GeneralSkins              스킨
Configuration_SmallSkins                작은 스킨
Configuration_TinySkins                 아주 작은 스킨

Advanced_Error1                         '%s' 는 이미 무시되는 단어로 등록된 듯
Advanced_Error2                         무시되는 단어는 알파벳, 숫자,., _, -, 또는 @ 만을 쓸 수 있습니다.
Advanced_Error3                         '%s' 가 무시되는 단어 목록에 추가되었습니다.
Advanced_Error4                         '%s' 는 무시되는 단어 목록에 없습니다.
Advanced_Error5                         '%s' 가 무시되는 단어 목록에서 제거되었습니다
Advanced_StopWords                      무시되는 단어들
Advanced_Message1                       팝파일은 다음의 자주 사용되는 단어를 무시합니다:
Advanced_AddWord                        단어 추가
Advanced_RemoveWord                     단어 제거

History_Filter                          &nbsp;(다음 버킷만을 보임:<font color="%s">%s</font>)
History_FilterBy                        필터됨:
History_Search                          &nbsp;(발신/제목으로 검색: %s)
History_Title                           최근 메일
History_Jump                            메일로 가기
History_ShowAll                         모두 보임
History_ShouldBe                        맞는 분류
History_NoFrom                          발신자 없음
History_NoSubject                       제목 없음
History_ClassifyAs                      다음으로 분류함:
History_MagnetUsed                      사용된 자석
History_ChangedTo                       다음으로 변경됨:<font color="%s">%s
History_Already                         현재 분류:<font color="%s">%s</font>
History_RemoveAll                       모두 제거
History_RemovePage                      현재 보이는 목록만 제거
History_Remove                          히스토리로부터 제거하기 위해서는 클릭하십시오
History_SearchMessage                   발신/제목으로부터 검색
History_NoMessages                      메일 없음
History_ShowMagnet                      자석으로 분류됨
History_Magnet                          &nbsp;(자석으로 분류된 것만 보임)
History_ResetSearch                     초기화

Password_Title                          비밀번호
Password_Enter                          비밀번호 입력
Password_Go                             시작
Password_Error1                         잘못된 비밀번호

Security_Error1                         보안포트는 반드시 1부터 65535사이의 숫자여야 합니다.
Security_Stealth                        스텔스 모드 / 서버 동작
Security_NoStealthMode                  아니오 (스텔스 모드)
Security_ExplainStats                   (이것이 켜지면 팝파일은 하루에 한번씩 다음의 세가지 값을 www.usethesource.com에 보냅니다 - bc (만드신 버킷 수), mc (팝파일이 분류한 메시지 수) and ec (분류 오류 건수).  이것들은 파일로 저장되며 팝파일이 어떻게 사용되며 얼마나 잘 작동하는지에 관한 통계를 공표할때 사용됩니다. 제 웹서버는 5일간 로그파일을 보존하고 그 후 삭제합니다. 개개의 IP주소와 통계 간에 어떠한 연관관계도 저장되지 않습니다.)
Security_ExplainUpdate                  (이것이 켜지면 팝파일은 하루에 한번씩 다음의 세가지 값을 www.usethesource.com에 보냅니다 - ma (설치하신 팝파일의 메이저 버전 번호), mi (설치하신 팝파일의 마이너 버전 번호), bn (설치하신 팝파일의 빌드 번호). 팝파일은 새 버전이 있으면 페이지 맨 위쪽에 그래픽 형태로 그 결과를 표시합니다. 제 웹서버는 5일간 로그파일을 보존하고 그 후 삭제합니다. 개개의 IP주소와 업데이트 체크 간에 어떠한 연관관계도 저장되지 않습니다.)
Security_PasswordTitle                  사용자 인터페이스 비밀번호
Security_Password                       비밀번호
Security_PasswordUpdate                 비밀번호를 %s로 변경했습니다.
Security_AUTHTitle                      보안 패스워드 인증
Security_SecureServer                   보안 서버
Security_SecureServerUpdate             보안 서버를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_SecurePort                     보안 포트
Security_SecurePortUpdate               포트를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_POP3                           원격지로부터 POP3 연결을 허용(팝파일 재시작 필요)
Security_UI                             원격지로부터 HTTP (사용자 웹 인터페이스)연결을 허용(팝파일 재시작 필요)
Security_UpdateTitle                    자동 업데이트 체크
Security_Update                         팝파일 최신 버전을 매일 체크함
Security_StatsTitle                     통계 보고
Security_Stats                          매일 통계를 보냄

Magnet_Error1                           자석 '%s' 는 이미 버킷 '%s'에 존재합니다.
Magnet_Error2                           새 자석 '%s'는 '%s'자석과 충돌함(버킷:'%s'). 따라서 혼동의 우려가 있으므로 새 자석은 추가되지 않았습니다.
Magnet_Error3                           새 자석인 '%s'을 버킷 '%s'에 생성
Magnet_CurrentMagnets                   현재 자석
Magnet_Message1                         다음 자석은 지정된 버킷으로 메일이 항상 분류되도록 합니다.
Magnet_CreateNew                        새 자석 생성
Magnet_Explanation                      세 종류의 자석이 가능합니다:</b> <ul><li><b>발신주소 또는 이름:</b> 예: john@company.com (특정 이메일 주소로), <br />company.com (company.com에서 보내는 모든 메일), <br />John Doe:Jonh Doe만 일치, John:첫단어가 John이면 모두 일치</li><li><b>수신자 메일주소 또는 이름:</b> 발신주소용 자석과 동일하나 수신자에 작용함</li> <li><b>제목의 단어:</b> 예)안녕하세요 는 제목란의 모든 안녕하세요 와 일치</li></ul>
Magnet_MagnetType                       자석 종류
Magnet_Value                            값
Magnet_Always                           항상 다음 버킷으로

Bucket_Error1                           영어 소문자와 - 와 _만을 사용하실 수 있습니다.
Bucket_Error2                           %s(이)라는 이름의 버킷은 이미 있습니다.
Bucket_Error3                           %s(이)라는 이름으로 버킷을 생성
Bucket_Error4                           공백이 아닌 단어를 입력하십시오.
Bucket_Error5                           %s 버킷을 %s로 변경하였습니다.
Bucket_Error6                           삭제된 버킷 %s
Bucket_Title                            요약
Bucket_BucketName                       버킷 이름
Bucket_WordCount                        단어 수
Bucket_WordCounts                       단어 수
Bucket_UniqueWords                      유일한 단어
Bucket_SubjectModification              제목 변경
Bucket_ChangeColor                      색상 변경
Bucket_NotEnoughData                    데이터가 충분치 않음
Bucket_ClassificationAccuracy           분류 정확도
Bucket_EmailsClassified                 분류된 이메일
Bucket_EmailsClassifiedUpper            분류된 이메일
Bucket_ClassificationErrors             분류 오류
Bucket_Accuracy                         정확도
Bucket_ClassificationCount              분류 수
Bucket_ResetStatistics                  통계 초기화
Bucket_LastReset                        마지막 초기화
Bucket_CurrentColor                     %s의 현재 색상은 %s입니다.
Bucket_SetColorTo                       %s의 색상을 %s으로 설정
Bucket_Maintenance                      유지 보수
Bucket_CreateBucket                     다음 이름의 버킷 생성
Bucket_DeleteBucket                     다음 이름의 버킷 삭제
Bucket_RenameBucket                     다음 이름의 버킷 이름 변경
Bucket_Lookup                           검색
Bucket_LookupMessage                    버킷에서 다음 단어를 검색
Bucket_LookupMessage2                   다음 단어에 대한 검색 결과
Bucket_LookupMostLikely                 <b>%s</b>는 <font color="%s">%s</font>에 나타날 확률이 가장 높습니다.
Bucket_DoesNotAppear                    <p><b>%s</b>는 어느 버킷에도 나타나지 않습니다.
Bucket_DisabledGlobally                 적용안함
Bucket_To                               =>
Bucket_Quarantine                       격리

SingleBucket_Title                      %s의 상세내용
SingleBucket_WordCount                  버킷 단어 수
SingleBucket_TotalWordCount             전체 단어 수
SingleBucket_Percentage                 전체의 비율
SingleBucket_WordTable                  %s의 단어 표
SingleBucket_Message1                   별표 붙은(*) 단어들은 이번 팝파일 세션에서 분류에 사용되었습니다. 단어를 클릭하시면 버킷에 포함될 확률을 화면 아래 오른쪽에서 보실 수 있습니다.
SingleBucket_Unique                     %s : 유일

Session_Title                           팝파일 세션이 만료되었습니다.
Session_Error                           팝파일 세션이 만료되었습니다. 팝파일을 종료 후 재시작 했기 때문일 것이며, 위의 링크 중 하나를 누르시면 계속하실 수 있습니다. 

Header_MenuSummary                      이것은 제어센터의 각기 다른 페이지를 접근할 수 있는 메뉴입니다.
History_MainTableSummary                이것은 최근 수신된 메일의 발신인과 제목을 보여주며 재검토하고 재분류할 수 있도록 해주는 메뉴입니다. 제목 라인을 클릭하시면 메일 내용을 보실 수 있으며 아울러, 분류가 된 이유를 보실 수 있습니다. 맞는 분류 칸에서는 메일이 어느 버킷에 속하는지 지정하시거나 분류를 취소하실 수 있습니다. '삭제' 칸에서는 특정 메시지를 히스토리로부터 지울 수 있습니다.
History_OpenMessageSummary              이것은 이메일의 본문을 담고 있으며, 분류에 사용된 단어가 가장 관련높은 버킷에 따라 하이라이트되어 있습니다.
Bucket_MainTableSummary                 이것은 분류 버킷에 대한 개관을 제공합니다. 각 행은 버킷명, 버킷의 총 단어 수, 각 버킷에 속한 개별 단어 수, 메일이 분류 되었을때 제목이 변경 되었는지 여부, 메일을 그 버킷으로 격리 시킬 것인지 여부, 그리고 버킷과 관련된 사항을 표시할 색깔을 고를 수 있는 표로 구성되어 있습니다.
Bucket_StatisticsTableSummary           이것은 팝파일의 전반적인 성능에 관한 세 종류의 통계를 제공합니다. 1. 분류가 얼마나 정확한가, 2. 얼마나 많은 메일이, 어느 버킷에 분류되었는가, 3. 얼마나 많은 단어가 각 버킷에 속하며, 그들의 상대적인 퍼센트 비율이 어떻게 되는가.
Bucket_MaintenanceTableSummary          이것은 버킷의 생성/삭제/변경 할수 있는 페이지를 제공하며 상대적인 확률보기 위해 모든 버킷에 담긴 단어를 검색하는 메뉴입니다.
Bucket_AccuracyChartSummary             이것은 이메일 분류의 정확도를 그래픽으로 표시합니다.
Bucket_BarChartSummary                  이것은 각각의 버킷에 대한 할당 비율(퍼센트)를 그래픽으로 표시합니다. 이것은 분류된 메일의 수와 총 단어 수에 모두 사용됩니다.
Bucket_LookupResultsSummary             이것은 코퍼스(단어집)의 단어가 가지는 확률을 보여줍니다. 각각의 버킷에 대해, 단어 출현 빈도와 그 버킷에 포함될 확률, 그리고 그 단어가 메일에 존재할 경우 버킷 점수에 미치는 전반적인 영향을 보여줍니다.
Bucket_WordListTableSummary             이것은 특정 버킷에 대한 모든 단어를 각 행의 첫 단어로 정렬하여 나열합니다.
Magnet_MainTableSummary                 이것은 고정된 단어에 따라 자동적으로 메일을 분류하기 위한 자석들을 보여줍니다. 각 줄은 어떻게 자석이 정의되어 있는지, 어느 버킷에 넣을 것인지, 그리고 자석을 지울 버튼을 보여줍니다.
Configuration_MainTableSummary          이것은 팝파일의 설정을 조절하기 위한 여러 폼으로 구성됩니다. 
Configuration_InsertionTableSummary     이것은 이메일 프로그램(아웃룩 등등)에 메일을 넘겨주기 전에 헤더나 제목란을 변경할 것인지 설정할 버튼을 보여줍니다.
Security_MainTableSummary               이것은 팝파일의 전체 구성의 보안에 영향을 주는 제어 항목을 제공합니다. 즉, 자동적으로 업데이트를 체크할 것인가, 개발에 참고하기 위해 팝파일의 성능에 대한 통계를 프로그램 제작자의 웹사이트로 전송할 것인가를 정할 수 있습니다.
Advanced_MainTableSummary               이것은 팝파일이 메일을 분류할때 무시하는 단어(너무 흔한 단어) 목록을 제공합니다. 단어들은 첫 글자에 의해 정렬되어 있습니다.