#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"

using namespace cocos2d;

class Jobs: public CCObject
{
public:
    Jobs(int _x, int _y){
        x = _x;
        y = _y;
    }
    int x, y;
};

class GondorScene : public cocos2d::CCLayer
{
protected:
    CCSprite *player;
    
    CCArray *targets, *bullets, *p2Bullets, *myBullets;

    float scale;
    int paths[1000];
    int currentLevel;
    int creaturesLeft;
    int score;
    int tickCounter;

    CCLabelTTF *infoLabel, *scoreLabel;

    bool gameIsOver, multiPlayer;

    CCMenu *menuMulti, *menuSingle, *gameOverButton;

public:
    static bool connected;
    static bool locked;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    void kickShotandY(const char *xs, const char *ys);

    bool joinGame(int w, int h);

    void leaveRoom();
#endif

    void runJobs(float interval);

    void setInfoText(const char* str);

    void fillPaths(int* arr, int length);

    static GondorScene *activeGondor;
    
    // Method 'init' in cocos2d-x returns bool, instead of 'id' in cocos2d-iphone (an object pointer)
    virtual bool init();

    void createPaths();

    ~GondorScene();

    void startGame();
    void singlePlayerGame();
    void multiPlayerGame();

    void playerLeft();

    void setScore(int score);

    CCRect getRect(CCSprite *sprite);

    // there's no 'id' in cpp, so we recommend to return the class instance pointer
    static cocos2d::CCScene* scene();
    
    // a selector callback
    void menuCloseCallback(CCObject* pSender);
    
    void ccTouchesEnded(CCSet* touches, CCEvent* event);
    
    static void gotFire(int x, int y, int wo, int ho);

    void fireBall(CCPoint location);
    
    void moveDone(CCNode* node);
    
    void tick(float interval);
    
    void collisionTest(float interval);
    
    void addTarget();

    // preprocessor macro for "static create()" constructor ( node() deprecated )
    CREATE_FUNC(GondorScene);
};

#endif // __HELLOWORLD_SCENE_H__
