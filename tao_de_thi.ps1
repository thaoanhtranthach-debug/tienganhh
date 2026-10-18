$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$output = 'C:\Users\AdminMoi\Documents\GIUAKI\Huong_dan_Giua_ky_Reading_v09.docx'
$paragraphs = New-Object 'System.Collections.Generic.List[object]'

function Add-Paragraph([string]$style, [string]$text) {
    $script:paragraphs.Add([pscustomobject]@{ Style = $style; Text = $text })
}

# Dữ liệu thực tế cho Part 5 (Câu hỏi 101 - 130)
$part5Data = @{
    101 = @{ Prompt = "Every batch of sauce at Generita's Bistro is expertly processed meticulously by _____ chefs."; Choices = @{A="they"; B="their"; C="them"; D="themselves"}; Answer = "D" };
    102 = @{ Prompt = "Computerization of medical records _____ increases a physician's ability to diagnose and treat patients."; Choices = @{A="great"; B="greatly"; C="greatness"; D="greatest"}; Answer = "B" };
    103 = @{ Prompt = "At Rojelle's Fine Dining, we use the freshest _____ available to make our salads."; Choices = @{A="applications"; B="subjects"; C="ingredients"; D="factors"}; Answer = "C" };
    104 = @{ Prompt = "Professor Benguigui will present his paper _____ the natural history conference tomorrow."; Choices = @{A="by"; B="at"; C="of"; D="on"}; Answer = "B" };
    105 = @{ Prompt = "The chefs are still waiting for a _____ date for the new convection oven that was ordered two weeks ago."; Choices = @{A="shipper"; B="ships"; C="shipments"; D="shipping"}; Answer = "D" };
    106 = @{ Prompt = "Mr. Kang works _____ with our internal team members as well as various regional sales representatives."; Choices = @{A="mildly"; B="nearly"; C="closely"; D="narrowly"}; Answer = "C" };
    107 = @{ Prompt = "Fashion designer Hye-Ja Pak knows _____ to update her line in response to changing tastes."; Choices = @{A="and"; B="when"; C="need"; D="for"}; Answer = "B" };
    108 = @{ Prompt = "The samba class was so well _____ that the Yulara Dance School decided to make the course a permanent offering."; Choices = @{A="attended"; B="educated"; C="gathered"; D="protected"}; Answer = "A" };
    109 = @{ Prompt = "The factory will be situated away _____ the city's residential area to reduce complaints about noise and emissions."; Choices = @{A="from"; B="about"; C="with"; D="out"}; Answer = "A" };
    110 = @{ Prompt = "Ms. Kuramoto selected the most _____ mailing option available."; Choices = @{A="economical"; B="economy"; C="economize"; D="economized"}; Answer = "A" };
    111 = @{ Prompt = "Companies without information technology specialists can _____ on Vyber Software Advisers for assistance with online services."; Choices = @{A="reliable"; B="reliably"; C="rely"; D="relying"}; Answer = "C" };
    112 = @{ Prompt = "Next year, our team will have a new task, _____ is to review design portfolios."; Choices = @{A="although"; B="which"; C="after"; D="because"}; Answer = "B" };
    113 = @{ Prompt = "Cook the meat for 30 minutes to ensure _____ readiness to be eaten."; Choices = @{A="both"; B="this"; C="its"; D="that"}; Answer = "C" };
    114 = @{ Prompt = "Amoxitron's research team will hire _____ interns to assist with laboratory duties."; Choices = @{A="given"; B="several"; C="whole"; D="natural"}; Answer = "B" };
    115 = @{ Prompt = "_____ the new acai juice blend has proved so popular, we should move quickly to increase our production volume."; Choices = @{A="If"; B="Whether"; C="Since"; D="Unless"}; Answer = "C" };
    116 = @{ Prompt = "New emissions standards have forced Rider Auto to modify the process of engine _____﻿."; Choices = @{A="construction"; B="constructed"; C="constructive"; D="construct"}; Answer = "A" };
    117 = @{ Prompt = "Maki Kayano's book offers techniques for _____ business tasks with speed and precision."; Choices = @{A="executing"; B="equipping"; C="returning"; D="involving"}; Answer = "A" };
    118 = @{ Prompt = "To control costs, updated credit card readers will be installed in branch stores _____﻿."; Choices = @{A="gradual"; B="gradually"; C="more gradual"; D="most gradual"}; Answer = "B" };
    119 = @{ Prompt = "In this quarter, the Montel Beverage Company is expecting sales _____ £160,000 and £180,000."; Choices = @{A="without"; B="among"; C="throughout"; D="between"}; Answer = "D" };
    120 = @{ Prompt = "Because Mount Akoyola is so challenging for climbers, _____ have reached its peak."; Choices = @{A="any"; B="either"; C="other"; D="few"}; Answer = "D" };
    121 = @{ Prompt = "King Street Bridge will be closed in the month of September _____ repair work."; Choices = @{A="because of"; B="so that"; C="as if"; D="rather than"}; Answer = "A" };
    122 = @{ Prompt = "Ms. Taniguchi's supervisor commended her for negotiating _____ with Furuyama Corporation."; Choices = @{A="effective"; B="effecting"; C="effected"; D="effectively"}; Answer = "D" };
    123 = @{ Prompt = "Staff members may reserve the conference room _____ they need it."; Choices = @{A="somewhere"; B="whatever"; C="everything"; D="anytime"}; Answer = "D" };
    124 = @{ Prompt = "The public relations director must have a high level of _____ in English and Spanish."; Choices = @{A="proficiency"; B="advancement"; C="routine"; D="strength"}; Answer = "A" };
    125 = @{ Prompt = "Patterson Products _____ seeks innovative ways of meeting changing consumer demand."; Choices = @{A="dually"; B="favorably"; C="continually"; D="generically"}; Answer = "C" };
    126 = @{ Prompt = "Mr. Volante is working at home tomorrow so he _____ the technical report without any distractions."; Choices = @{A="can finish"; B="would finish"; C="finished"; D="has been finishing"}; Answer = "A" };
    127 = @{ Prompt = "All of the billing procedures remain the same, _____ new payment codes need to be inserted into the invoice documents."; Choices = @{A="in order that"; B="during"; C="across from"; D="except that"}; Answer = "D" };
    128 = @{ Prompt = "The lightweight design of the new sedan is _____ because it can cause the vehicle to slide on icy roads."; Choices = @{A="possible"; B="mechanical"; C="questionable"; D="multiple"}; Answer = "C" };
    129 = @{ Prompt = "When the bank president retired, the common _____ was that the vice president would take over."; Choices = @{A="assume"; B="assumption"; C="assuming"; D="assumable"}; Answer = "B" };
    130 = @{ Prompt = "West Bengali Airlines _____ fees for oversized items that are still within weight limitations."; Choices = @{A="invites"; B="cooperates"; C="transports"; D="waives"}; Answer = "D" };
}

# Dữ liệu thực tế cho Part 6 và Part 7 (Các đoạn văn và câu hỏi)
$passagesData = @(
    @{
        Id = 'P6-131-134'; Part = '6'; Type = 'email'; Pages = '5';
        Text = "To: pmendoza@factmail.co`nFrom: recruiting@analystsassoc.org`nDate: May 2`nSubject: Joining ASA`n`nDear Mr. Mendoza,`nThank you for expressing your interest in our organization during the recent [131]. It was a pleasure meeting you at the ASA booth during the Weber Information Systems Convention. As you may recall from our conversation, we discussed how ASA membership [132] your career through networking opportunities as well as the industry insights offered in our monthly newsletter. The normal fee for members is just $120 a year; however, we are currently offering a new-member discount. [133]`nIf you are still interested in joining, please reply to [134] with your mailing address. I will then forward you an application packet.`n`nSincerely,`nAshlee Loren, President`nAssociation of Systems Analysts";
        Questions = @(
            @{ Num = 131; Prompt = "Choose the best word for blank 131."; Choices = @{A="election"; B="broadcast"; C="conference"; D="performance"}; Answer = "C" },
            @{ Num = 132; Prompt = "Choose the best word for blank 132."; Choices = @{A="can benefit"; B="is benefiting"; C="has benefited"; D="will have benefited"}; Answer = "A" },
            @{ Num = 133; Prompt = "Choose the best sentence for blank 133."; Choices = @{A="Discounts on rental cars are included in the annual membership."; B="Our jobs board is quite comprehensive."; C="We are the first organization of our kind."; D="This month you can join for just half the usual rate."}; Answer = "D" },
            @{ Num = 134; Prompt = "Choose the best word for blank 134."; Choices = @{A="it"; B="me"; C="them"; D="anyone"}; Answer = "B" }
        )
    },
    @{
        Id = 'P6-135-138'; Part = '6'; Type = 'email'; Pages = '6';
        Text = "To: Sam Heinz`nFrom: Northways Professional Development`nSent: April 20`nSubject: Workshop 4/28-4/30`n`nDear Workshop Participants,`nWe look forward to seeing you at the digital storytelling workshop. On the first day, when you enter the Albin College campus, attendants will [135] you to lot 43 and the Toteman Building. We will begin each day in conference room 9. Coffee, tea, snacks, and fruit [136] in the mornings. Lunch [137] will be sandwiches and salads from Black Horse Restaurant.`nIn the afternoons, we will be working in the computer lab. We suggest that you assemble some images that you would like to use for your project. It will be [138] for you to have them saved on a digital storage device beforehand. If you have any questions, please e-mail us.`n`nVery Best,`nGina Kapuski";
        Questions = @(
            @{ Num = 135; Prompt = "Choose the best word for blank 135."; Choices = @{A="offer"; B="direct"; C="pass"; D="instruct"}; Answer = "B" },
            @{ Num = 136; Prompt = "Choose the best word for blank 136."; Choices = @{A="will be provided"; B="were provided"; C="providers"; D="are providing"}; Answer = "A" },
            @{ Num = 137; Prompt = "Choose the best sentence for blank 137."; Choices = @{A="Some prior experience working with digital files is assumed."; B="Please do not bring any copyrighted material to the workshop."; C="Please let us know if you have any dietary restrictions."; D="There is a one-time parking charge of fifteen dollars."}; Answer = "C" },
            @{ Num = 138; Prompt = "Choose the best word for blank 138."; Choices = @{A="useful"; B="surprised"; C="difficult"; D="amazing"}; Answer = "A" }
        )
    },
    @{
        Id = 'P6-139-142'; Part = '6'; Type = 'article'; Pages = '7';
        Text = "Venley Foods Responsive to Changing Consumers`nWho cares where the tomatoes in your salad actually came from? [139], an increasing number of people do, according to a study conducted by the Consumer Group. In fact, the study shows that many consumers would pay an average of 10 percent more when given the exact source of a fresh food product. [140] Some grocery stores, such as Venley Foods in Boston, have taken advantage of the trend and used it to implement branding and marketing. 'If we can tell a [141] story about our product,' says Venley Foods CEO Minji Kim, 'then we've added [142] in the minds of consumers.'";
        Questions = @(
            @{ Num = 139; Prompt = "Choose the best word for blank 139."; Choices = @{A="Carefully"; B="Apparently"; C="Formerly"; D="Rarely"}; Answer = "B" },
            @{ Num = 140; Prompt = "Choose the best sentence for blank 140."; Choices = @{A="Fresh food can be refrigerated for up to two days."; B="Many grocery stores have been extending their hours."; C="Most studies are published in consumer magazines."; D="The number increases to 20 percent in large cities."}; Answer = "D" },
            @{ Num = 141; Prompt = "Choose the best word for blank 141."; Choices = @{A="smarts"; B="smartly"; C="smarter"; D="smartness"}; Answer = "B" },
            @{ Num = 142; Prompt = "Choose the best word for blank 142."; Choices = @{A="value"; B="time"; C="obstacles"; D="bonus"}; Answer = "A" }
        )
    },
    @{
        Id = 'P6-143-146'; Part = '6'; Type = 'article'; Pages = '8';
        Text = "Nylobe, Inc., Announces Newest Development Project`nSEATTLE (May 1)-Researchers at technology firm Nylobe, Inc., are working to develop a sensor capable of detecting corrosion caused by environmental exposure. Corrosion is a major contributor to losses in the aircraft industry each year. 'This will be a major [143] for commercial airline fleets,' says Mel Laveau, Nylobe's CEO. 'The sensor will decrease both labor and maintenance costs without being too expensive.'`nAccording to Ms. Laveau, the sensor will work by detecting corrosion in its early stages, when the problem can be corrected simply by removing the corroded material. [144] In the structure of large aircraft, some critical joints can be particularly susceptible to corrosion. [145], the sensor can be used to inspect these areas and then target the most likely areas of concern.";
        Questions = @(
            @{ Num = 143; Prompt = "Choose the best word for blank 143."; Choices = @{A="financially"; B="financed"; C="financial"; D="finances"}; Answer = "C" },
            @{ Num = 144; Prompt = "Choose the best word for blank 144."; Choices = @{A="balance"; B="examination"; C="expectation"; D="asset"}; Answer = "D" },
            @{ Num = 145; Prompt = "Choose the best sentence for blank 145."; Choices = @{A="This will reduce the need for making expensive structural repairs."; B="The parts have all been replaced with higher quality materials."; C="The next stage of the project involves scanning the affected areas."; D="Its style and sleek design made it popular with the public."}; Answer = "A" },
            @{ Num = 146; Prompt = "Choose the best word for blank 146."; Choices = @{A="Meanwhile"; B="Similarly"; C="Otherwise"; D="Fortunately"}; Answer = "D" }
        )
    },
    @{
        Id = 'P7-147-148'; Part = '7'; Type = 'invoice'; Pages = '9';
        Text = "Invoice 3987`nShawqi Office Services, Dubai, UAE`n18 October`nJenkins Press, P.O. Box 2291, Dubai, UAE`nService: On 14 October, replaced bulb and repaired paper tray on copier per call received on 12 October. Replaced copy ink in two machines. Performed routine yearly maintenance on five copiers per existing service contract.`nLabor cost: AED 330.00 | Paper tray: AED 50.00 | Bulb: AED 30.00 | Copy ink: AED 220.00 | Total: AED 630.00`nTotal amount must be received by 31 October.";
        Questions = @(
            @{ Num = 147; Prompt = "What is indicated about Jenkins Press?"; Choices = @{A="It has several offices around the world."; B="Its copiers get checked every year."; C="Its office equipment is outdated."; D="It is a new customer of Shawqi Office Services."}; Answer = "B" },
            @{ Num = 148; Prompt = "When is payment due?"; Choices = @{A="October 12"; B="October 14"; C="October 18"; D="October 31"}; Answer = "D" }
        )
    },
    @{
        Id = 'P7-149-151'; Part = '7'; Type = 'advertisement'; Pages = '10';
        Text = "Harbour View Apartment - Porthmadog, Wales`nThis one-bedroom apartment is perfect for a holiday escape! Located in a quiet area, it boasts a patio with a lovely view of the harbour. Recently renovated, the unit includes an eat-in kitchen with stove, refrigerator, microwave, and coffeepot; bathroom with walk-in shower; and a living room with a large-screen TV. Other amenities include short distance to restaurants/shops, 5-minute walk to beach, heat/electricity included, towels/linens provided, daily cleaning (extra fee), wireless internet (extra fee).`nSigning a contract by March 30 will reduce rental cost by 10%. Contact Dylan Barrett at dbarrett@telarentals.co.uk.";
        Questions = @(
            @{ Num = 149; Prompt = "Who would the advertisement most likely interest?"; Choices = @{A="Business travelers"; B="Residents of Porthmadog"; C="Property investors"; D="Short-term vacationers"}; Answer = "D" },
            @{ Num = 150; Prompt = "What is indicated about the rental fee?"; Choices = @{A="It includes tours of historic places."; B="It does not cover all of the apartment's features."; C="It includes vouchers to use at local restaurants."; D="It requires a minimum 30 percent deposit in advance."}; Answer = "B" },
            @{ Num = 151; Prompt = "Why should an individual contact Mr. Barrett by March 30?"; Choices = @{A="To get a discount on rent"; B="To schedule apartment renovations"; C="To rent the last available property"; D="To sell the property before the end of the season"}; Answer = "A" }
        )
    },
    @{
        Id = 'P7-152-153'; Part = '7'; Type = 'text-message-chain'; Pages = '11';
        Text = "Jason Salter (1:45 P.M.): Liz, the meeting is starting in fifteen minutes. Where are you?`nLiz Ortiz (1:47 P.M.): The train has been stopped on the tracks for a while. There seems to be some kind of problem. I still hope to make the meeting.`nJason Salter (1:50 P.M.): Okay. I'll save you a seat.`nLiz Ortiz (1:59 P.M.): There's just been an announcement. There's a disabled train up ahead. It'll be awhile.`nJason Salter (2:00 P.M.): Don't worry. If there are any questions for our department, I'll handle them.`nLiz Ortiz (2:01 P.M.): Thanks. I'll call you later.";
        Questions = @(
            @{ Num = 152; Prompt = "What is suggested about Mr. Salter?"; Choices = @{A="He is leading the meeting."; B="He commutes to work by train."; C="He has many questions for Ms. Ortiz."; D="He works in the same department as Ms. Ortiz."}; Answer = "D" },
            @{ Num = 153; Prompt = "At 1:59 P.M., what does Ms. Ortiz imply when she writes, 'It'll be awhile'?"; Choices = @{A="The meeting is running late."; B="She is still preparing her notes."; C="She will likely miss the meeting."; D="She has not boarded the train yet."}; Answer = "C" }
        )
    },
    @{
        Id = 'P7-154-155'; Part = '7'; Type = 'email'; Pages = '12';
        Text = "From: tbogosian@sardhasconvention.com`nTo: pradalaily@dmcv.com`nDate: 22 March`nSubject: Your reservation`n`nDear Ms. Prada,`nThank you for choosing Sardha's Banquet Hall to host your event on 30 August. Unfortunately, West Hall will be under renovation in August, and we will be unable to accommodate your group in that room. However, your party will fit comfortably in East Hall. This room features floor-to-ceiling windows and a full view of the river. The 15 percent deposit we have received will hold the reservation. Total price of $1,600 includes a full-course meal...`nTomas Bogosian, General Manager";
        Questions = @(
            @{ Num = 154; Prompt = "What is one purpose of the e-mail?"; Choices = @{A="To cancel a reservation"; B="To apologize for an error"; C="To indicate a room change"; D="To request an extra deposit"}; Answer = "C" },
            @{ Num = 155; Prompt = "What is suggested about Ms. Prada?"; Choices = @{A="She has paid her bill in full."; B="She eats at Sardha's regularly."; C="She works in the food industry."; D="She made the reservation online."}; Answer = "D" }
        )
    },
    @{
        Id = 'P7-156-157'; Part = '7'; Type = 'memo'; Pages = '13';
        Text = "MEMO`nTo: All Employees`nFrom: IT Supervisor`nDate: 27 May`nSubject: OS Update`nAll company computers in the Melbourne and Victoria offices require an update to the operating system to prepare for new accounting software arriving in July. Technicians will install it beginning 3 June through 16 June. Employees taking holiday during this period must inform IT Support immediately.";
        Questions = @(
            @{ Num = 156; Prompt = "When is the installation of the operating system expected to be finished?"; Choices = @{A="In the first week of June"; B="In the middle of June"; C="At the end of June"; D="In the first week of July"}; Answer = "B" },
            @{ Num = 157; Prompt = "Who is asked to contact IT Support?"; Choices = @{A="Employees who do not need the accounting software"; B="Accountants already using the new operating system"; C="Staff who work outside the offices"; D="Employees who are taking time off"}; Answer = "D" }
        )
    },
    @{
        Id = 'P7-158-160'; Part = '7'; Type = 'letter'; Pages = '14';
        Text = "Clarke-Ellis Construction letter to Ida Gutierrez (Darling Cove Inn). [1]. Main roof is in good condition, but porch roof is worn beyond repair. [2]. Clarke-Ellis can replace porch roof using commercial-grade materials by West Indies Weatherproofing, Inc. Total cost: $3,260. [3]. Please call to schedule. [4].";
        Questions = @(
            @{ Num = 158; Prompt = "Why did Mr. Clarke write the letter?"; Choices = @{A="To provide a work proposal"; B="To ask for a project extension"; C="To request an inspection report"; D="To submit a revised cost estimate"}; Answer = "A" },
            @{ Num = 159; Prompt = "What is indicated about West Indies Weatherproofing, Inc.?"; Choices = @{A="It is installing a new porch at Darling Cove Inn."; B="It provides painting services."; C="It produces roofing materials."; D="It is owned by Clarke-Ellis Construction."}; Answer = "C" },
            @{ Num = 160; Prompt = "In which position marked [1], [2], [3], and [4] does 'It must be replaced.' best belong?"; Choices = @{A="[1]"; B="[2]"; C="[3]"; D="[4]"}; Answer = "B" }
        )
    },
    @{
        Id = 'P7-161-164'; Part = '7'; Type = 'advertisement'; Pages = '15';
        Text = "Position: Assistant Editor at Goldhorse Press (Charlotte, NC). Independent book publishing company focusing on North American gardening for over 50 years. Responsibilities: assist editors, develop manuscripts. Requirements: bachelor's degree, 1+ year experience, attention to detail, team member. E-mail resume to humanresources@goldhorsepress.com.";
        Questions = @(
            @{ Num = 161; Prompt = "What title would most likely be published by Goldhorse Press?"; Choices = @{A="Growing Your Baking Business"; B="A Tour Guide to North Carolina"; C="Planting Perennial Flowers"; D="The Efficient Executive"}; Answer = "C" },
            @{ Num = 162; Prompt = "What is indicated about Goldhorse Press?"; Choices = @{A="It is hiring two assistant editors."; B="It provides insurance to employees."; C="It publishes trade journals."; D="It is a newly established company."}; Answer = "B" },
            @{ Num = 163; Prompt = "What is a requirement for the advertised position?"; Choices = @{A="A passion for gardening"; B="An aptitude for noticing details"; C="A master's degree in a related field"; D="An ability to work without supervision"}; Answer = "B" },
            @{ Num = 164; Prompt = "What are applicants asked to do?"; Choices = @{A="Submit a job application form"; B="Submit a list of references"; C="Indicate availability"; D="Indicate desired pay"}; Answer = "D" }
        )
    },
    @{
        Id = 'P7-165-168'; Part = '7'; Type = 'online-chat'; Pages = '16-17';
        Text = "Online chat between Derek Marshall, Mai Chung, Nikita Tamboli, and Anthony Rossi regarding the merger with Ridgewood, Inc. Derek Boutique will keep 35 stores open; 12 stores will vacate and move inventory in 5 weeks.";
        Questions = @(
            @{ Num = 165; Prompt = "Where do the writers most likely work?"; Choices = @{A="At a marketing firm"; B="At a clothing company"; C="At a real estate agency"; D="At a newspaper publisher"}; Answer = "B" },
            @{ Num = 166; Prompt = "How many stores will be closing?"; Choices = @{A="5"; B="6"; C="12"; D="35"}; Answer = "C" },
            @{ Num = 167; Prompt = "At 8:25 A.M., what does Ms. Tamboli most likely mean when she writes, 'That would work'?"; Choices = @{A="The current inventory will be doubled."; B="Ridgewood, Inc., will close in two weeks."; C="Mr. Marshall will meet with the managers."; D="She can schedule the moves in the proposed time frame."}; Answer = "D" },
            @{ Num = 168; Prompt = "What is suggested about Ms. Chung and Mr. Rossi?"; Choices = @{A="They supervise other employees."; B="They often shop at Ridgewood, Inc."; C="They recently went to lunch together."; D="They have concerns about the merger."}; Answer = "A" }
        )
    },
    @{
        Id = 'P7-169-171'; Part = '7'; Type = 'article'; Pages = '18';
        Text = "Article: 'From the Shadows to the Limelight' by Calum Ellwood about Dr. Esther Nujoma and her book Shining Behind Shadows highlighting 12 peers from Africa and Asia in agricultural biotechnology.";
        Questions = @(
            @{ Num = 169; Prompt = "What is NOT indicated about Dr. Nujoma?"; Choices = @{A="She has visited Chile."; B="She is a talented writer."; C="She is based out of Namibia."; D="She was interviewed by the London Daily Register."}; Answer = "D" },
            @{ Num = 170; Prompt = "What does Mr. Ellwood say about Shining Behind Shadows?"; Choices = @{A="It focuses on scientists from Africa and Asia."; B="It was released three years ago."; C="It details why Dr. Nujoma chose her career."; D="It describes various branches of biotechnology."}; Answer = "A" },
            @{ Num = 171; Prompt = "In which position marked [1], [2], [3], and [4] does 'Its focus is not on applying biotechnology in real-life situations.' best belong?"; Choices = @{A="[1]"; B="[2]"; C="[3]"; D="[4]"}; Answer = "B" }
        )
    },
    @{
        Id = 'P7-172-175'; Part = '7'; Type = 'notice'; Pages = '19';
        Text = "Kingston-Garnet Island Passenger Ferry Service notice. Runs daily from 15 May for 8 weeks. Bicycles permitted (load first). No motorized vehicles on Garnet Island. Overnight parking $25 in Kingston lot.";
        Questions = @(
            @{ Num = 172; Prompt = "What is indicated about the ferry service?"; Choices = @{A="It is available only seasonally."; B="Its boats were recently upgraded."; C="It takes an hour to reach the island."; D="It runs more frequently on weekends."}; Answer = "A" },
            @{ Num = 173; Prompt = "What is true about bicyclists on the ferries?"; Choices = @{A="They are last to board the boat."; B="They must purchase a special ticket."; C="They cannot travel on the 7:30 P.M. trip."; D="They should arrive at the terminal early."}; Answer = "D" },
            @{ Num = 174; Prompt = "What is not allowed on Garnet Island?"; Choices = @{A="Renting bicycles"; B="Driving cars"; C="Camping overnight"; D="Taking photographs"}; Answer = "B" },
            @{ Num = 175; Prompt = "What is indicated about the ferry tickets?"; Choices = @{A="They can be purchased at stores in Kingston."; B="They are less expensive for children."; C="They vary in price depending on the time of travel."; D="They are more expensive if purchased on the boat."}; Answer = "C" }
        )
    },
    @{
        Id = 'P7-176-180'; Part = '7'; Type = 'receipt-and-email'; Pages = '20-21';
        Text = "Green Stripe Press receipt and email from Jason Ho (Shoebox Mountain). Ordered 6 accounting record books, sent 7. Also received complimentary calendar and wants 2 more.";
        Questions = @(
            @{ Num = 176; Prompt = "Why was Mr. Ho not charged a shipping fee?"; Choices = @{A="He took advantage of a promotion."; B="He made the purchase for his company."; C="He picked up his order in person."; D="He overpaid for shipping on a previous order."}; Answer = "B" },
            @{ Num = 177; Prompt = "What is true about Mr. Ho's order?"; Choices = @{A="It was damaged in transit."; B="It included fragile items."; C="It was paid for by check."; D="It was delivered on time."}; Answer = "D" },
            @{ Num = 178; Prompt = "According to the e-mail, what was Mr. Ho sent by mistake?"; Choices = @{A="A castle book he did not order"; B="A calendar for last year"; C="An incorrect refund check"; D="An extra accounting book"}; Answer = "D" },
            @{ Num = 179; Prompt = "What is one reason Mr. Ho wrote the e-mail?"; Choices = @{A="To offer praise for an item"; B="To complain about a price"; C="To order some photo albums"; D="To recommend a graphic designer"}; Answer = "A" },
            @{ Num = 180; Prompt = "In the e-mail, the phrase 'our way' in paragraph 2, line 4, is closest in meaning to"; Choices = @{A="in our style"; B="to our address"; C="at our expense"; D="for our benefit"}; Answer = "B" }
        )
    },
    @{
        Id = 'P7-181-185'; Part = '7'; Type = 'contact-form-and-email'; Pages = '22-23';
        Text = "Contact form from Roger Witmondt (movie location scout) to Hilgrave Historical Commission and reply from Brandi Schaertl suggesting old record store at 188 Main Street (owned by Luke Nylund).";
        Questions = @(
            @{ Num = 181; Prompt = "Why is Mr. Witmondt looking for a filming location in Hilgrave?"; Choices = @{A="It is known for its scenic mountain views."; B="It is a short distance from his office."; C="Its business district has appeared in other films."; D="Its buildings represent a particular time period."}; Answer = "D" },
            @{ Num = 182; Prompt = "On the contact form, the word 'critical' in paragraph 2, line 4, is closest in meaning to"; Choices = @{A="judgmental"; B="essential"; C="sustainable"; D="available"}; Answer = "B" },
            @{ Num = 183; Prompt = "What is implied about 188 Main Street?"; Choices = @{A="It was once used as a residence."; B="It is frequently visited by tourists."; C="It has several floors."; D="It has decorative design features."}; Answer = "D" },
            @{ Num = 184; Prompt = "What does Ms. Schaertl offer to do?"; Choices = @{A="Advertise a forthcoming film"; B="Arrange to have a building cleaned"; C="Connect Mr. Witmondt with a building's owner"; D="Help Mr. Witmondt acquire necessary permits from the town"}; Answer = "C" },
            @{ Num = 185; Prompt = "What does Ms. Schaertl suggest that Hilgrave needs?"; Choices = @{A="More publicity"; B="Additional parking"; C="A storage facility"; D="A business directory"}; Answer = "A" }
        )
    },
    @{
        Id = 'P7-186-190'; Part = '7'; Type = 'emails-and-web-page'; Pages = '24-25';
        Text = "Emails between Pragya Mehta and Cornelia Payne regarding lecture at Anson House (Freeport, The Bahamas) on 19 March about book 'The Transatlantic World of the Nineteenth Century'.";
        Questions = @(
            @{ Num = 186; Prompt = "Why did Dr. Mehta send the e-mail to Dr. Payne?"; Choices = @{A="To cancel a vacation plan"; B="To request lecture notes"; C="To confirm a meeting"; D="To offer an apology"}; Answer = "D" },
            @{ Num = 187; Prompt = "According to the second e-mail, what did Dr. Payne do?"; Choices = @{A="Arrange a delivery"; B="Give Mr. Halton a gift"; C="Revise her presentation"; D="Announce an address change"}; Answer = "A" },
            @{ Num = 188; Prompt = "What is indicated about Alphagamma Press?"; Choices = @{A="It has headquarters in The Bahamas."; B="It regularly ships materials to Anson House."; C="It published The Transatlantic World of the Nineteenth Century."; D="It is paying Dr. Payne's travel and accommodation expenses."}; Answer = "C" },
            @{ Num = 189; Prompt = "Where were Dr. Mehta and Dr. Payne most likely colleagues?"; Choices = @{A="In Mumbai"; B="In Freeport"; C="In Stoke-on-Trent"; D="In Charleston"}; Answer = "C" },
            @{ Num = 190; Prompt = "What is indicated about the Speaker Series in the Web page?"; Choices = @{A="Discounts are unavailable."; B="Reservations are optional."; C="Events are held in the morning."; D="Refreshments are not included."}; Answer = "B" }
        )
    },
    @{
        Id = 'P7-191-195'; Part = '7'; Type = 'advertisement-email-and-press-release'; Pages = '26-27';
        Text = "CRYN Group job posting (Director of Operations, etc.), email to Sven Arvidson from Maria Doro, and press release announcing Sven Arvidson as new director at Tayerson Ltd. (online marketer of nutritional supplements).";
        Questions = @(
            @{ Num = 191; Prompt = "According to the advertisement, what qualification is not required of applicants?"; Choices = @{A="A degree in business"; B="Previous employment in a managerial position"; C="Experience working overseas"; D="Online sales and marketing experience"}; Answer = "C" },
            @{ Num = 192; Prompt = "What most likely is the location of the position for which Mr. Arvidson applied?"; Choices = @{A="Latin America"; B="North America"; C="Europe"; D="Asia"}; Answer = "A" },
            @{ Num = 193; Prompt = "What does Ms. Doro ask Mr. Arvidson to provide in his reply?"; Choices = @{A="Information on his leadership skills"; B="His availability for an interview"; C="A current résumé"; D="The names of two references"}; Answer = "B" },
            @{ Num = 194; Prompt = "What job code did Mr. Arvidson most likely reference in his application?"; Choices = @{A="TL0015"; B="TL0023"; C="TL0027"; D="TL0045"}; Answer = "D" },
            @{ Num = 195; Prompt = "According to the press release, what does Tayerson Ltd. sell?"; Choices = @{A="Medical devices"; B="Accounting software"; C="Nutritional supplements"; D="Exercise equipment"}; Answer = "C" }
        )
    },
    @{
        Id = 'P7-196-200'; Part = '7'; Type = 'brochure-email-and-schedule'; Pages = '28-29';
        Text = "FGJ's Business Expert Series brochure about Prospect Data Purchasing webinar, email from Gino Stelleti to Sandra Lescure reviewing it, and upcoming webinar schedule.";
        Questions = @(
            @{ Num = 196; Prompt = "According to the brochure, who would benefit most from the Prospect Data Purchasing Webinar?"; Choices = @{A="A financial analyst"; B="A marketing manager"; C="A customer-service representative"; D="An information-technology specialist"}; Answer = "B" },
            @{ Num = 197; Prompt = "What was Mr. Stelleti's complaint about the Webinar?"; Choices = @{A="He did not like the format."; B="He did not learn anything new."; C="He had difficulty hearing everything."; D="He found the topic to be too complex."}; Answer = "B" },
            @{ Num = 198; Prompt = "What does Mr. Stelleti suggest about Ms. Carrera?"; Choices = @{A="She recently joined a new company."; B="She has experience managing databases."; C="She had asked him to sign up for the Webinar."; D="She tried to sell her company's services."}; Answer = "D" },
            @{ Num = 199; Prompt = "When will Mr. Stelleti most likely attend another Webinar?"; Choices = @{A="On June 1"; B="On June 12"; C="On July 5"; D="On July 17"}; Answer = "D" },
            @{ Num = 200; Prompt = "According to the schedule, what do all of the Webinars have in common?"; Choices = @{A="They cost the same amount."; B="They are held in the morning."; C="They last the same amount of time."; D="They are recorded for future playback."}; Answer = "C" }
        )
    }
)

# Xây dựng các hàm ghi đoạn văn Word
Add-Paragraph 'Title' 'KHUNG TAG ĐỀ THI TOEIC READING'
Add-Paragraph 'Subtitle' 'Reading v09 — 100 câu, Parts 5–7 (Điền đầy đủ nội dung)'
Add-Paragraph 'Subtitle' 'Mẫu nhập DOCX cho backend ASP.NET Core / C#'

Add-Paragraph 'Heading1' '1. Thông tin cấu trúc đề thi'
Add-Paragraph 'Normal' 'Đã điền đầy đủ 100 câu hỏi (101-200), nội dung đoạn văn bài đọc Part 6, Part 7 và đáp án chuẩn theo tài liệu đề thi.'

Add-Paragraph 'Heading1' '2. Nội dung chi tiết các phần thi'

Add-Paragraph 'Code' '<EXAM>'
Add-Paragraph 'Code' '  <TITLE>TOEIC Reading Test 09</TITLE>'
Add-Paragraph 'Code' '  <DURATION_MINUTES>75</DURATION_MINUTES>'
Add-Paragraph 'Code' '  <SHUFFLE_QUESTIONS>false</SHUFFLE_QUESTIONS>'
Add-Paragraph 'Code' '  <SHUFFLE_CHOICES>false</SHUFFLE_CHOICES>'

# Ghi Part 5
Add-Paragraph 'Code' '  <PART number="5">'
for ($i = 101; $i -le 130; $i++) {$q = $part5Data[$i]
    $page = 2; if ($i -ge 109 -and $i -le 120) {$page = 3 } elseif ($i -ge 121) {$page = 4 }
    Add-Paragraph 'Code' "    <QUESTION number=`"$i`">"
    Add-Paragraph 'Code' "      <PROMPT>$($q.Prompt)</PROMPT>"
    foreach ($opt in @('A', 'B', 'C', 'D')) {
        Add-Paragraph 'Code' "      <CHOICE id=`"$opt`">$($q.Choices[$opt])</CHOICE>"
    }
    Add-Paragraph 'Code' "      <CORRECT_ANSWER>$($q.Answer)</CORRECT_ANSWER>"
    Add-Paragraph 'Code' "      <SOURCE_PAGE>$page</SOURCE_PAGE>"
    Add-Paragraph 'Code' "    </QUESTION>"
}
Add-Paragraph 'Code' '  </PART>'

# Ghi Part 6
Add-Paragraph 'Code' '  <PART number="6">'
foreach ($p in ($passagesData \vert{} Where-Object {$_.Part -eq '6' })) {
    Add-Paragraph 'Code' "  <PASSAGE id=`"$($p.Id)`" type=`"$($p.Type)`" sourcePages=`"$($p.Pages)`">"
    Add-Paragraph 'Code' "    <PASSAGE_TEXT>$($p.Text)</PASSAGE_TEXT>"
    foreach ($q in$p.Questions) {
        Add-Paragraph 'Code' "    <QUESTION number=`"$($q.Num)`" passageRef=`"$($p.Id)`">"
        Add-Paragraph 'Code' "      <PROMPT>$($q.Prompt)</PROMPT>"
        foreach ($opt in @('A', 'B', 'C', 'D')) {
            Add-Paragraph 'Code' "      <CHOICE id=`"$opt`">$($q.Choices[$opt])</CHOICE>"
        }
        Add-Paragraph 'Code' "      <CORRECT_ANSWER>$($q.Answer)</CORRECT_ANSWER>"
        Add-Paragraph 'Code' "      <SOURCE_PAGE>$($p.Pages)</SOURCE_PAGE>"
        Add-Paragraph 'Code' "    </QUESTION>"
    }
    Add-Paragraph 'Code' "  </PASSAGE>"
}
Add-Paragraph 'Code' '  </PART>'

# Ghi Part 7
Add-Paragraph 'Code' '  <PART number="7">'
foreach ($p in ($passagesData \vert{} Where-Object {$_.Part -eq '7' })) {
    Add-Paragraph 'Code' "  <PASSAGE id=`"$($p.Id)`" type=`"$($p.Type)`" sourcePages=`"$($p.Pages)`">"
    Add-Paragraph 'Code' "    <PASSAGE_TEXT>$($p.Text)</PASSAGE_TEXT>"
    foreach ($q in$p.Questions) {
        Add-Paragraph 'Code' "    <QUESTION number=`"$($q.Num)`" passageRef=`"$($p.Id)`">"
        Add-Paragraph 'Code' "      <PROMPT>$($q.Prompt)</PROMPT>"
        foreach ($opt in @('A', 'B', 'C', 'D')) {
            Add-Paragraph 'Code' "      <CHOICE id=`"$opt`">$($q.Choices[$opt])</CHOICE>"
        }
        Add-Paragraph 'Code' "      <CORRECT_ANSWER>$($q.Answer)</CORRECT_ANSWER>"
        Add-Paragraph 'Code' "      <SOURCE_PAGE>$($p.Pages)</SOURCE_PAGE>"
        Add-Paragraph 'Code' "    </QUESTION>"
    }
    Add-Paragraph 'Code' "  </PASSAGE>"
}
Add-Paragraph 'Code' '  </PART>'
Add-Paragraph 'Code' '</EXAM>'

# Hàm escape XML
function Escape-XmlText([string]$text) {
    [System.Security.SecurityElement]::Escape($text)
}

$body = New-Object System.Text.StringBuilder
foreach ($paragraph in$paragraphs) {
    $safeText = Escape-XmlText$paragraph.Text
    $null =$body.Append('<w:p><w:pPr><w:pStyle w:val="' + $paragraph.Style + '"/></w:pPr><w:r><w:t xml:space="preserve">' + $safeText + '</w:t></w:r></w:p>')
}

$document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>' + $body.ToString() + '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="850" w:right="850" w:bottom="850" w:left="850" w:header="400" w:footer="400" w:gutter="0"/></w:sectPr></w:body></w:document>'
$styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos" w:eastAsia="Aptos"/><w:lang w:val="vi-VN"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="100" w:line="252" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:color w:val="174A7E"/><w:sz w:val="36"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:rPr><w:color w:val="52677F"/><w:sz w:val="23"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="260" w:after="120"/></w:pPr><w:rPr><w:b/><w:color w:val="174A7E"/><w:sz w:val="27"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Code"><w:name w:val="Code"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="0" w:line="210"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="16"/><w:color w:val="333333"/></w:rPr></w:style></w:styles>'
$rootRelationships = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
$documentRelationships = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>'
$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>'

$fileStream = [IO.File]::Open($output, [IO.FileMode]::Create)$archive = [System.IO.Compression.ZipArchive]::new($fileStream, [System.IO.Compression.ZipArchiveMode]::Create,$false)
foreach ($entryData in @(
    @{ Name = '[Content_Types].xml'; Text = $contentTypes },
    @{ Name = '_rels/.rels'; Text = $rootRelationships },
    @{ Name = 'word/document.xml'; Text = $document },
    @{ Name = 'word/styles.xml'; Text = $styles },
    @{ Name = 'word/_rels/document.xml.rels'; Text = $documentRelationships }
)) {
    $entry = $archive.CreateEntry($entryData.Name)
    $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))$writer.Write($entryData.Text)$writer.Dispose()
}
$archive.Dispose()$fileStream.Dispose()

Write-Output "Đã tạo thành công tệp Word chuẩn chứa đầy đủ nội dung tại: $output"