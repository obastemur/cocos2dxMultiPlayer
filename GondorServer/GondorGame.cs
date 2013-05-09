using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Threading;
using System.Web;
using PokeIn;
using PokeIn.Comet;

namespace GondorServer
{
    public class GondorGame:IDisposable
    {
        internal static Dictionary<string, string> sessionKeys = new Dictionary<string, string>(); 
        
        internal ConnectionDetails details;

        internal string otherPlayerId = "";
        public GondorGame(ConnectionDetails _details)
        {
            details = _details;
            string oldClid = "";

            lock(sessionKeys)
            {
                //kick the other player first
                if(sessionKeys.ContainsKey(_details.SessionId))
                {
                    oldClid = sessionKeys[_details.SessionId];
                }
                sessionKeys[_details.SessionId] = _details.ClientId;
            }

            if(oldClid!=string.Empty)
            {
                lock(waitingRoom)
                {
                    waitingRoom.Remove(oldClid);
                }
            }
        }

        public void playerFires(int location)
        {
            if(otherPlayerId!=string.Empty)
            {
                CometWorker.SendToClient(otherPlayerId, EXTML.Method("playerShot", location));
            }
        }

        internal void Log(string message)
        {
#if DEBUG
            if(Debugger.IsAttached)
                Debugger.Log(1,"",":::-" + message + "\r\n");
#endif
        }

        internal static HashSet<string> waitingRoom = new HashSet<string>();

        internal Size screenSize;
        internal Size opponentSize;

        public void joinGame(int w, int h)
        {
            screenSize = new Size(w,h);

            if (w == 0 || h == 0)
                return;

            lock (waitingRoom)
            {
                if (waitingRoom.Any())
                {
                    otherPlayerId = waitingRoom.First();
                    waitingRoom.Remove(otherPlayerId);
                }
                else
                {
                    waitingRoom.Add(details.ClientId);
                    Log(details.ClientId + " joined to room");
                    return;
                }
            }

            GondorGame gm = null;
            
            try
            {
                CometWorker.GetClientObject(otherPlayerId, "Server", out gm);
            }catch{}

            if(gm==null)
            {
                Log("Game object for " + otherPlayerId + " not found");
                lock(waitingRoom)
                {
                    waitingRoom.Add(details.ClientId);
                }
                return; 
            }

            int[] nums = prepareGame();
            Log(otherPlayerId + " game starts");
            opponentSize = gm.screenSize;
            gm.opponentSize = screenSize;

            gm.startGame(nums);

            gm.otherPlayerId = details.ClientId;
            startGame(nums);
            Log(details.ClientId + " game starts");
        }

        static int receivedShot = 0;
        public void gotShot(string xs, string ys)
        {
            string playerId = otherPlayerId;
            CometWorker.SendToClient(playerId, 
            EXTML.Method("playerShot:andY:andWidth:andHeight:",xs,ys, opponentSize.Width, opponentSize.Height));
        }

        static int randomizer = 0;
        private static int [] prepareGame()
        {
            int rand = Interlocked.Increment(ref randomizer);
            Interlocked.CompareExchange(ref randomizer, 100, 0);
            
            int[] numbers = new int[1000];

            Random rnd = new Random(rand);
            for (int n = 0; n < 1000; n++)
            {
                numbers[n] = rnd.Next() % 5;       
            }
            return numbers;
        }

        internal void startGame(int [] nums)
        {
            CometWorker.SendToClient(details.ClientId, EXTML.Method("creatureArray:",nums));
        }

        public void addPlayer(string playerId)
        {
            otherPlayerId = playerId;
        }

        public void leaveRoom()
        {
            lock (sessionKeys)
            {
                sessionKeys.Remove(details.ClientId);
            }

            lock (waitingRoom)
            {
                waitingRoom.Remove(details.ClientId);
            }

            if (otherPlayerId != string.Empty)
            {
                CometWorker.SendToClient(otherPlayerId, EXTML.Method("PlayerLeft"));
                otherPlayerId = "";
            }
        }

        public void Dispose()
        {
            Log(details.ClientId + " left the game");
            leaveRoom();
        }
    }
}