//generate the number between 1 to 37 to select the image
        var randomno = Math.floor(Math.random()*37) + 1;
        var dispimg = "banner"+randomno+".jpg";      
//adjusted height of picture from 87px to 64 and then 62px for border
        var imgtag = "<img src=/dhq/common/images/bannerimg/"+dispimg+" alt=banner image width=100% height=62px />";        
          document.write(imgtag);
