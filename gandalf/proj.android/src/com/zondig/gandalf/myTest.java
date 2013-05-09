package com.zondig.gandalf;

public class myTest {
	public void playerShotandYandWidthandHeight(String xs, String ys, Integer wo, Integer ho){
		String [] xarr = xs.split(";");
		String [] yarr = ys.split(";");
		
		for(int i=0;i<xarr.length;i++){
			if(xarr[i].length()==0)
				continue;
			
			int x = Integer.parseInt(xarr[i]);
			int y = Integer.parseInt(yarr[i]);
			
			gandalf.playerShot(x, y, wo, ho);
		}
	}
	
	public void creatureArray(Object [] arr)
	{
		int [] numbers = new int[arr.length];
		for(int i=0;i<arr.length;i++){
			numbers[i] = (Integer)arr[i];
		}
		gandalf.creatureArray(numbers);
	}
	
	public void playerLeft(){
		gandalf.playerLeft();
	}

	public static PokeIn.Java.Client activeClient;

}
