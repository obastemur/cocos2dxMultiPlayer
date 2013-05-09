#include "GondorScene.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "myTest.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <android/log.h>
#define  LOG_TAG    "GondorGame"
#define  LOGIT(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#else
NOT SUPPORTED
#endif

using namespace cocos2d;

CCScene* GondorScene::scene()
{
    // 'scene' is an autorelease object
    CCScene *scene = CCScene::create();
    
    // 'layer' is an autorelease object
    GondorScene *layer = GondorScene::create();
    
    GondorScene::activeGondor = layer;
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

GondorScene *GondorScene::activeGondor = NULL;
bool GondorScene::locked = false;
bool GondorScene::connected = false;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
bool GondorScene::joinGame(int w, int h)
{
	if(!connected){
		setInfoText("Not Connected!");
		return false;
	}
    
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "com/zondig/gandalf/gandalf"
                                       ,"joinGame"
                                       ,"(II)V"))
	{
		t.env->CallStaticVoidMethod(t.classID,t.methodID, w, h);
		t.env->DeleteLocalRef(t.classID);
	}
    
	return true;
}

void GondorScene::leaveRoom()
{
	if(!connected){
		return;
	}
    
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "com/zondig/gandalf/gandalf"
                                       ,"leaveRoom"
                                       ,"()V"))
	{
		t.env->CallStaticVoidMethod(t.classID,t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void GondorScene::kickShotandY(const char *xs, const char *ys)
{
	if(!connected){
		return;
	}
    
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "com/zondig/gandalf/gandalf"
                                       ,"fireShot"
                                       ,"(Ljava/lang/String;Ljava/lang/String;)V"))
	{
        jstring strX = t.env->NewStringUTF(xs);
        jstring strY = t.env->NewStringUTF(ys);
		t.env->CallStaticVoidMethod(t.classID,t.methodID, strX, strY);
		t.env->DeleteLocalRef(t.classID);
	}
}
#endif

GondorScene::~GondorScene()
{
    if(targets){
        targets->release();
        targets = NULL;
    }
    
    if(bullets){
        bullets->release();
        bullets = NULL;
    }
    
    if(p2Bullets){
        p2Bullets->release();
        p2Bullets = NULL;
    }
    
    if(myBullets){
        myBullets->release();
        myBullets = NULL;
    }
}

// on "init" you need to initialize your instance
bool GondorScene::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !CCLayer::init() )
    {
        return false;
    }
    
    targets = new CCArray();
    bullets = new CCArray();
    
    //2nd player bullets
    p2Bullets = new CCArray();
    
    myBullets = new CCArray();
    
    score = 0;
    tickCounter = 0;
    gameIsOver = false;
    infoLabel = NULL;
    
    CCDirector::sharedDirector()->setDisplayStats(false);
    
    // ask director the window size
    CCSize size = CCDirector::sharedDirector()->getWinSize();
    scale = size.width/480;
    
    // add a "close" icon to exit the progress. it's an autorelease object
    CCMenuItemImage *pCloseItem = CCMenuItemImage::create(
                                                          "CloseNormal.png",
                                                          "CloseSelected.png",
                                                          this,
                                                          menu_selector(GondorScene::menuCloseCallback) );
    pCloseItem->setPosition( ccp(size.width - (20*scale), (20*scale)) );
    
    pCloseItem->setScale(scale);
    
    // create menu, it's an autorelease object
    CCMenu* pMenu = CCMenu::create(pCloseItem, NULL);
    pMenu->setPosition( CCPointZero );
    this->addChild(pMenu, 1);
    
    CCSprite* bg = CCSprite::create("bg.jpg", CCRectMake(0, 0, 1024, 768));
    bg->setScale(scale);
    bg->setPosition(ccp(size.width/2,size.height/2));
    this->addChild(bg);
    
    player = CCSprite::create("gandalf.png", CCRectMake(0, 0, 70, 70));
    player->setScale(scale);
    player->setPosition(ccp(size.width/2,scale*35));
    this->addChild(player);
    
    this->setTouchEnabled(true);
    
    setInfoText("Gondor Game!");
    
    scoreLabel = CCLabelTTF::create("00000", "Helvatica", scale*20);
    CCSize scSize = scoreLabel->getContentSize();
    scoreLabel->setPosition(ccp(scSize.width/2, scSize.height/2));
    scoreLabel->setColor(ccc3(190,0,0));
    
    this->addChild(scoreLabel);
    
    CCMenuItemImage *singleButton = CCMenuItemImage::create(
                                                            "singleplayer.png",
                                                            "singleplayer.png",
                                                            this,
                                                            menu_selector(GondorScene::singlePlayerGame) );
    
    singleButton->setScale(scale);
    singleButton->setPosition( ccp(size.width/2, (size.height/2) - (scale*30)) );
    
    // create menu, it's an autorelease object
    menuSingle = CCMenu::create(singleButton, NULL);
    menuSingle->setPosition( CCPointZero );
    this->addChild(menuSingle, 1);
    
    CCMenuItemImage *multiButton = CCMenuItemImage::create(
                                                           "multiplayer.png",
                                                           "multiplayer.png",
                                                           this,
                                                           menu_selector(GondorScene::multiPlayerGame) );
    
    multiButton->setScale(scale);
    multiButton->setPosition( ccp(size.width/2, (size.height/2) + (scale*30)) );
    
    // create menu, it's an autorelease object
    menuMulti = CCMenu::create(multiButton, NULL);
    menuMulti->setPosition( CCPointZero );
    this->addChild(menuMulti, 1);
    
    fireBall(ccp(size.width/2,0));
    return true;
}

void GondorScene::setScore(int score)
{
	char strScore[6];
	sprintf(strScore,"%.5d", score);
    
    scoreLabel->setString(strScore);
    CCSize scSize = scoreLabel->getContentSize();
    scoreLabel->setPosition(ccp(scSize.width/2, scSize.height/2));
}

void GondorScene::playerLeft()
{
    multiPlayer = false;
    gameIsOver = true;
}

void GondorScene::singlePlayerGame(){
    
    if(multiPlayer){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        [myTest leaveLobby];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        leaveRoom();
#else
        NOT SUPPORTED
#endif
    }
    
    multiPlayer = false;
    currentLevel = 1;
    createPaths();
    startGame();
}

void GondorScene::multiPlayerGame(){
    multiPlayer = true;
    CCSize winSize = CCDirector::sharedDirector()->getWinSize();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSNumber* w = [NSNumber numberWithInt:winSize.width];
    NSNumber* h = [NSNumber numberWithInt:winSize.height];
    
    [myTest joinGame:w andHeight:h];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    if(!joinGame(winSize.width, winSize.height))
    	return;
#else
    NOT SUPPORTED
#endif
    
    this->removeChild(menuMulti);
    menuMulti = NULL;
    setInfoText("Waiting for another player");
}

void GondorScene::startGame(){
    this->removeChild(menuSingle);
    if(menuMulti!=NULL)
        this->removeChild(menuMulti);
    
    this->schedule(schedule_selector(GondorScene::runJobs), 0.30);
    this->schedule(schedule_selector(GondorScene::collisionTest));
}

void GondorScene::runJobs(float interval)
{
    if(tickCounter++>15){
        tick(interval);
        tickCounter = 0;
    }
    
    while(locked);
    
    locked = true;
    CCArray *arrP2 = new CCArray();
    CCArray *arrMY = new CCArray();
    
    if(p2Bullets->count()>0)
    {
        arrP2->addObjectsFromArray(p2Bullets);
        p2Bullets->removeAllObjects();
    }
    if(myBullets->count()>0)
    {
        arrMY->addObjectsFromArray(myBullets);
        myBullets->removeAllObjects();
    }
    locked = false;
    
    
    if (arrMY->count()>0){
        CCObject *ob;
        
        //this method receives a call aprox each 0.3 secs (max touch can be 15? 15 * 6 = 90 since resolution number can't be bigger than 6 digits for a while!)
        char xs[90];
        char ys[90];
        xs[0] = '\0';
        ys[0] = '\0';
        
        int n = 0;
        CCARRAY_FOREACH(arrMY, ob){
            //stay safe
            if(n++>14)//we could also measure the length of string but it takes more resource
                break;
            
            Jobs *po = dynamic_cast<Jobs*>(ob);
            sprintf(xs, "%s;%d",xs,po->x);
            sprintf(ys, "%s;%d",ys,po->y);
        }
        
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        [myTest kickShot:[NSString stringWithUTF8String:xs] andY:[NSString stringWithUTF8String:ys]];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        kickShotandY(xs, ys);
#else
        NOT SUPPORTED
#endif
        arrMY->removeAllObjects();
    }
    
    arrMY->release();
    
    if (arrP2->count()>0){
        CCObject *ob;
        CCARRAY_FOREACH(arrP2, ob){
            Jobs *po = dynamic_cast<Jobs*>(ob);
            fireBall(ccp(po->x,po->y));
        }
        arrP2->removeAllObjects();
    }
    arrP2->release();
}

CCRect GondorScene::getRect(cocos2d::CCSprite *sprite)
{
    CCPoint pos = sprite->getPosition();
    
    CCSize size = sprite->getContentSize();
    
    float w = 2 * size.width * scale / 3;
    float h = 2 * size.height * scale / 3;
    
    float x = pos.x - (w/2);
    float y = pos.y - (h/2);
    
    
    return CCRectMake(x, y, w, h);
}

void GondorScene::collisionTest(float interval)
{
    if(gameIsOver)
        return;
    
    CCArray *removeBullets = new CCArray();
    
    CCObject *bt, *tg;
    
    CCARRAY_FOREACH(bullets, bt){
        CCSprite *bullet = dynamic_cast<CCSprite*>(bt);
        CCRect rBullet = getRect(bullet);
        
        CCARRAY_FOREACH(targets, tg){
            CCSprite *target = dynamic_cast<CCSprite*>(tg);
            CCRect rTarget = getRect(target);
            
            if(rBullet.intersectsRect(rTarget)){
                this->removeChild(target);
                this->removeChild(bullet);
                targets->removeObject(target);
                removeBullets->addObject(bullet);
                //score += 5;
                //setScore(score);
                break;
            }
        }
    }
    
    CCARRAY_FOREACH(removeBullets, bt){
        CCSprite *bullet = dynamic_cast<CCSprite*>(bt);
        bullets->removeObject(bullet);
    }
    
    removeBullets->release();
}

void GondorScene::tick(float interval){
    if(gameIsOver)
        return;
    
    if(infoLabel!=NULL){
        this->removeChild(infoLabel);
        infoLabel = NULL;
        this->schedule(schedule_selector(GondorScene::tick), 0.8);
    }
    
    if(interval==2.0)
        return;
    
    for(int n=0;n<currentLevel;n++){
        addTarget();
        
        if(creaturesLeft<0){
            currentLevel++;
            
            char levelStr[30];
            sprintf(levelStr, "Level %d", currentLevel);
            setInfoText(levelStr);
            
            createPaths();
            
            this->schedule(schedule_selector(GondorScene::tick), 2.0);
            break;
        }
    }
}

void GondorScene::fillPaths(int* arr, int length)
{
    currentLevel = 2;
    for(int i=0;i<length;i++){
        paths[i] = arr[i];
    }
    creaturesLeft = length;
    startGame();
}

void GondorScene::createPaths()
{
    for(int n=0;n<currentLevel*50;n++){
        paths[n] = rand()%5;
    }
    
    creaturesLeft = currentLevel * 50;
}

void GondorScene::addTarget(){
    
    creaturesLeft--;
    if(creaturesLeft<0)
        return;
    
    const char* creatures[] = {"gollum.png", "orc1.png", "orc2.png", "lurtz.png"};
    
    int nPath = paths[creaturesLeft];
    
    CCSprite* creature = CCSprite::create(creatures[(nPath + creaturesLeft)%4], CCRectMake(0,0,70,70));
    
    creature->setScale(scale);
    
    CCSize size = CCDirector::sharedDirector()->getWinSize();
    int w = size.width - (4 * ((scale*70)));
    w/=2;
    int h = size.height;
    int f = nPath * (scale*70);
    
    creature->setPosition(ccp(w + f, h));
    this->addChild(creature);
    creature->setTag(2);
    
    targets->addObject(creature);
    
    CCMoveTo *action = CCMoveTo::create(6.0, ccp(w+f, 70*scale));
    creature->runAction(CCSequence::create(action, CCCallFuncN::create(this, callfuncN_selector(GondorScene::moveDone)), NULL));
}

void GondorScene::ccTouchesEnded(CCSet *touches, CCEvent *event)
{
    CCTouch* touch = (CCTouch*)touches->anyObject();
    CCPoint location = touch->getLocationInView();
    location = CCDirector::sharedDirector()->convertToGL(location);
    
    if(multiPlayer){
        while(locked);
        locked = true;
        myBullets->addObject(new Jobs(location.x, location.y));
        locked = false;
    }
    
    fireBall(location);
}

void GondorScene::gotFire(int x, int y, int wo, int ho)
{
	CCSize size = CCDirector::sharedDirector()->getWinSize();
	float rx = 1.2 * (size.width/(float)wo);
	float ry = 1.2 * (size.height/(float)ho);
    
    Jobs *job = new Jobs(x*rx,y*ry);
    while(GondorScene::activeGondor->locked);
    
    GondorScene::activeGondor->locked = true;
    GondorScene::activeGondor->p2Bullets->addObject(job);
    GondorScene::activeGondor->locked = false;
}

void GondorScene::fireBall(cocos2d::CCPoint location)
{
    setScore(score++);
    if(gameIsOver)
        return;
    
    for(float n = 0;n<(float)currentLevel*0.70f; n++){
        CCSprite *ball = CCSprite::create("ball.png", CCRectMake(0,0,70,70));
        ball->setScale(scale/2.0);
        
        CCSize size = CCDirector::sharedDirector()->getWinSize();
        ball->setPosition(ccp(size.width/2,(n*10) + scale*35));
        
        int x = location.x - (size.width/2);
        int y = location.y - (scale*35);
        
        float total = sqrt( (x*x) + (y*y) );
        float duration = total/size.height;
        
        this->addChild(ball);
        ball->setTag(1);
        bullets->addObject(ball);
        
        CCMoveTo *action = CCMoveTo::create(duration, location);
        CCSequence *seq = CCSequence::create(action, CCCallFuncN::create(this, callfuncN_selector(GondorScene::moveDone)), NULL);
        ball->runAction(seq);
    }
}

void GondorScene::moveDone(CCNode* node)
{
    CCSprite* sprite = (CCSprite*) node;
    this->removeChild(sprite);
    
    if(sprite->getTag()==1){
        bullets->removeObject(sprite);
    }
    else if(sprite->getTag() == 2){
        gameIsOver = true;
        
        setInfoText("Game is Over!");
    }
}

void GondorScene::setInfoText(const char *str)
{
	if(infoLabel!=NULL){
		this->removeChild(infoLabel);
		infoLabel = NULL;
	}
    
    CCSize size = CCDirector::sharedDirector()->getWinSize();
    infoLabel = CCLabelTTF::create(str, "Helvatica", scale * 30);
    infoLabel->setPosition(ccp(size.width/2,size.height - (scale*35)));
    infoLabel->setColor(ccc3(190,0,0));
    this->addChild(infoLabel);
}

void GondorScene::menuCloseCallback(CCObject* pSender)
{
    CCDirector::sharedDirector()->end();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
