import "commonReactions/all.dsl";

context 
{
    // declare input variables phone and name  - these variables are passed at the outset of the conversation. In this case, the phone number and customer’s name 
    input phone: string;

    // declare storage variables 
    output first_name: string = "";
    output last_name: string = "";
    output time: string = "";
    output c_time: string = "";
    output order: {[x:string]:string;}[] = [];
    output feedback: string = "";
    output rating: string = ""; 
    output address: string = ""; 
    output c_address: string = ""; 
    output c_order: {[x:string]:string;}[] = [];

    counter1: number = 0;
    counter2: number = 0;
    counter3: number = 0;
    namecounter: number = 0;
    test: string = "test";

}

// declaring external functions


start node root 
{
    do 
    {
        #connectSafe($phone);
        #waitForSpeech(1000);
        #sayText("Hi, you've called ACME Cafe at 2000 High Street, Boston. I'm Dasha. Your artificially intelligent hostess.");
        #sayText("You can place a rapid pick up, delivery or catering order with me. How can I help you today?");
        #log($test);
        wait *;
    }   
    transitions 
    {
    }
}

//pick up 
digression takeout
{
    conditions {on #messageHasIntent("takeout");}
    do 
    {
        if ($namecounter == 0)
        {
            set $namecounter = 1;
            #log($namecounter);
            #sayText("Perfect. I can help with that. What is your name please?");
            wait *; // wait for a response 

        }
        else 
        {
            goto takeout;
        }
    }
    transitions 
    {
        takeout_2: goto takeout_2 on #messageHasData("first_name");  
        takeout: goto takeout_2;
    }
}

node takeout_2
{
    do 
    {
        if ($namecounter <= 1)
        {
            set $first_name =  #messageGetData("first_name")[0]?.value??"";
            set $last_name =  #messageGetData("last_name")[0]?.value??"";
            #sayText("Pleased to meet you " + $first_name + ". When will you like to pick up your order?");
            set $namecounter = $namecounter + 1; 
        }
        else 
        {
            #sayText("When will you like to pick up your order?");
        }
        #log("name:  " + $first_name + " " + $last_name);
        wait*;
    }
    transitions
    {
        takeout_3: goto takeout_3 on #messageHasData("time"); 
    }
}

node takeout_3
{
    do
    {
        set $time =  #messageGetData("time")[0]?.value??"";
        #say("place_order");
        wait*;
    }
    transitions
    {
        takeout_4: goto takeout_4 on #messageHasData("order");
    }
}

node takeout_4
{
    do
    {
        set $order =  #messageGetData("order");
        #log($order);
        #sayText("Perfect. Let me just make sure I got that right.");
        var food = #messageGetData("order");
        var res = "You want ";
        for (var item in food)
        {
            set res = res + "," + (item.value ?? "");            
        }
        #sayText(res);
        #sayText("Is that right?");
        wait *;
    }
    transitions
    {
        takeout_5: goto takeout_5 on #messageHasIntent("yes");
        try_again: goto takeout_3 on #messageHasIntent("no");
    }
}

node takeout_5
{
    do
    {
        #sayText("Perfect. Your order total is thirty nine dollars and eighty three cents. We don't take card payment over the phone."); 
        #sayText("You will have to pay when you arrive to pick up your order. Do you want curbside pickup or will you go into the cafe to get your order? ");
        wait*;
    }
    transitions
    {
        takeout_curbside: goto takeout_curbside on #messageHasIntent("curbside");
        takeout_instore: goto takeout_instore on  #messageHasIntent("instore");
    }
}

node takeout_curbside
{
    do
    {
        #sayText("Great! We will have the order ready for curbside pick up for " + $first_name + " " + $last_name + " at " + $time); 
        #sayText(". At the 2000 High Street Acme  cafe. Is there anything else I can help you with today?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("no"); 
        can_help: goto can_help on #messageHasIntent("yes");
    }
}

node takeout_instore
{
    do
    {
        #sayText("Great! We will have the order ready for in store pick up for " + $first_name + " " + $last_name + " at " + $time + ". At the 2000 High Street Acme Bread cafe. Is there anything else I can help you with today?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("no"); 
        can_help: goto can_help on #messageHasIntent("yes");
    }
}

// delivery
digression delivery
{
    conditions {on #messageHasIntent("takeout");}
    do 
    {
        if ($namecounter == 0)
        {
            #sayText("Perfect. I can help with that. What is your name please?");
            set $namecounter = 1;
            #log($namecounter);
            wait *; // wait for a response 

        }
        else 
        {
            goto delivery;
        }        
    }
    transitions 
    {
        delivery_2: goto delivery_2 on #messageHasData("first_name"); // when Dasha identifies that the user's phrase contains "name" data, as specified in the named entities section of data.json, a transfer to node node_2 happens 
        delivery: goto delivery_2;
    }

}

node delivery_2
{
    do 
    {
        set $first_name =  #messageGetData("first_name")[0]?.value??"";
        set $last_name =  #messageGetData("last_name")[0]?.value??"";
        if ($namecounter == 0)
        { 
            if ($counter1 == 0)
            {
                #sayText("Plased to meet you " + $first_name + ". At what address do you want your ACme Bread order delivered?");
                set $counter2 = $counter2 + 1; 
            }
            else 
            {
                #sayText("Let's try this again. What is the address where you want to take the delivery?");
            }
            wait*;
        }
        else 
        #sayText("At what address do you want your Acme Bread order delivered?");
        wait*;
    }
    transitions
    {
        delivery_3: goto delivery_3 on #messageHasData("address"); 
    }
}

node delivery_3
{
    do
    {
        set $address =  #messageGetData("address")[0]?.value??"";
        #sayText("Thank you. Let's confirm, you want the food delivered at " + $address + ". Is this right? ");
        wait*;
    }
    transitions
    {
        delivery_4: goto delivery_4 on #messageHasIntent("yes");
        wrong: goto delivery_2 on #messageHasIntent("no");
    }
}

node delivery_4
{
    do
    {
        #sayText("And what time will you take the delivery?");
        wait*;
    }
    transitions
    {
        delivery_5: goto delivery_5 on #messageHasData("time");
    }
}

node delivery_5
{
    do
    {
        set $time =  #messageGetData("time")[0]?.value??"";
        #say("place_order");
        wait*;
    }
    transitions
    {
        delivery_6: goto delivery_6 on #messageHasData("order");
    }
}

node delivery_6
{
    do
    {
        set $order =  #messageGetData("order");
        #log($order);
        #sayText("Perfect. Let me just make sure I got that right.");
        var food = #messageGetData("order");
        var res = "You want ";
        for (var item in food)
        {
            set res = res + "," + (item.value ?? "");            
        }
        #sayText(res);
        #sayText("Is that right?");
        wait *;
    }
    transitions
    {
        delivery_7: goto delivery_7 on #messageHasIntent("yes");
        try_again: goto delivery_5 on #messageHasIntent("no");
    }
}

node delivery_7
{
    do
    {
        #sayText("Perfect. Your order total is thirty nine dollars and eighty three cents. We will deliver to " + $first_name + " " + $last_name + " at " + $time + " at the address of " + $address + ". Is there anything else I can help you with today?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("no"); 
        can_help: goto can_help on #messageHasIntent("yes");
    }
}

// catering 
digression catering
{
    conditions {on #messageHasIntent("catering");}
    do
    {
        if ($namecounter == 0)
        {
            #sayText("Perfect. I can help with that. What is your name please?");
            set $namecounter = 1;
            #log($namecounter);
            wait *; // wait for a response 

        }
        else 
        {
            goto cater;
        }       
    }
    transitions 
    {
        catering_2: goto catering_2 on #messageHasData("first_name"); // when Dasha identifies that the user's phrase contains "name" data, as specified in the named entities section of data.json, a transfer to node node_2 happens 
        cater: goto catering_2;
    }
    onexit 
    {
        catering_2: do
        {
        set $first_name =  #messageGetData("first_name")[0]?.value??"";
        set $last_name =  #messageGetData("last_name")[0]?.value??"";
        }
    }
}

node catering_2
{
    do 
    {
        #log($first_name);
        #log($last_name);
        #log($c_address);
        #sayText( $first_name + ". Will you like your catering order delivered or will you want to pick it up at store?");
        wait*;
    }
    transitions
    {
        catering_deliver: goto c_deliver on #messageHasIntent("delivery"); 
        catering_instore: goto c_instore on #messageHasIntent("takeout");
    }
}

node c_instore
{
    do
    {
        #sayText("I do apologize but it seems we will not be able to prepare a catering order for pick up at the 2000 High Street Acme Bread location.");
        #sayText("We will however deliver it wherever you want it at no extra charge. Is this okay?");
        wait*;
    }
    transitions
    {
        c_deliver: goto c_deliver on #messageHasIntent("yes");
        can_help_then: goto can_help_then on #messageHasIntent("no");
    }
}

node c_deliver
{
    do
    {
        if ($counter2 == 0)
        {
            #log($first_name);
            #log($last_name);
            #log($c_address);
            #sayText("At what address do you want your Acme Bread catering order delivered?");
            set $counter2 = $counter2 + 1; 
        }
        else 
        {
            #sayText("Let's try this again. What is the address where you want to take the delivery?");
        }
        wait*;
    }
    transitions
    {
        c_deliver_2: goto c_deliver_2 on #messageHasData("address"); 
    }
}

node c_deliver_2
{
    do
    {
        set $c_address =  #messageGetData("address")[0]?.value??"";
        #sayText("Thank you. Let's confirm, you want the food delivered at " + $c_address + ". Is this right? ");
        wait*;
    }
    transitions
    {
        c_deliver_3: goto c_deliver_3 on #messageHasIntent("yes");
        wrong: goto c_deliver on #messageHasIntent("no");
    }
}

node c_deliver_3
{
    do
    {
        #sayText("And what time will you take the delivery?");
        wait*;
    }
    transitions
    {
        c_deliver_4: goto c_deliver_4 on #messageHasData("time");
    }
}

node c_deliver_4

{
    do
    {
        set $c_time =  #messageGetData("time")[0]?.value??"";
        #sayText("How many people do you want to serve?");
        wait*;
    }
    transitions
    {
        c_deliver_5: goto c_deliver_5 on #messageHasData("people");
    }
}

node c_deliver_5
{
    do
    {
        #sayText("Before I take your order, would you like me to tell you about our most popular bundles and platters?");
        wait*;
    }
    transitions
    {
        c_deliver_6: goto c_deliver_6 on #messageHasIntent("no");
        bundles: goto bundles on #messageHasIntent("yes");
    }
}

node bundles
{
    do 
    {
        #sayText("We have the Seasonal Salads and Sandwiches. Morning Fruit & Pastry Platters. and Boxed Salads.");
        goto c_deliver_6;
    }
    transitions
    {
        c_deliver_6: goto c_deliver_6;
    }

}


node c_deliver_6
{
    do
    {

        #say("place_order_catering");
        wait*;
    }
    transitions
    {
        c_deliver_7: goto c_deliver_7 on #messageHasData("order");
    }
}

node c_deliver_7
{
    do
    {
        set $c_order =  #messageGetData("order");
        #log($c_order);
        #log($first_name);
        #log($last_name);
        #log($c_address);
        #sayText("Perfect. Let's confirm your order.");
        var food = #messageGetData("order");
        var res = "You want ";
        for (var item in food)
        {
            set res = res + "," + (item.value ?? "");            
        }
        #sayText(res);
        #sayText("Is that right?");
        wait *;
    }
    transitions
    {
        c_deliver_8: goto c_deliver_8 on #messageHasIntent("yes");
        try_again: goto c_deliver_6 on #messageHasIntent("no");
    }
}



node c_deliver_8
{
    do
    {
        #sayText("Perfect. Your order total is three hundred and six dollars and thirteen cents. We will deliver a feast  to ");
        #sayText( $first_name + " " + $last_name + " at " + $time + " at the address of " + $c_address + ". Is there anything else I can help you with today?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("no"); 
        can_help: goto can_help on #messageHasIntent("yes");
    }
}




//final and additional 
node can_help 
{
    do
    {
        #sayText("How can I help you?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("nevermind");
        catering: goto catering_2 on #messageHasIntent("catering");
    }
}

node can_help_then
{
    do
    {
        #sayText("How can I help you then?");
        wait*;
    }
    transitions
    {
        final: goto final on #messageHasIntent("nevermind");
    }
}

node final
{
    do
    {
        #sayText("Before you go, can you please give me a bit of feedback. How would you rate your ordering experience on the scale of zero to ten?");
        wait*;
    }
    transitions
    {
        rating_evaluation: goto rating_evaluation on #messageHasData("rating");
    }
}

node rating_evaluation 
{
    do 
    {
        set $rating =  #messageGetData("rating")[0]?.value??""; 
        #log("User rating is: " + $rating);
        var rating_num = #parseInt($rating); 
        if ( rating_num >=7 ) 
        {
            goto rate_positive; 
        }
        else
        {
            goto rate_negative;
        }
    }
    transitions
    {
        rate_positive: goto rate_positive; 
        rate_negative: goto rate_negative;
    }
}

node rate_positive
{
    do
    {
        #sayText("Thank you for such a high rating " + $first_name + "! Keep coming back to Acme!");
        exit;
    }
}

node rate_negative
{
    do 
    {
        #sayText("Sorry to hear you were not completely satisfied. What could have been done better?");
        wait*;
    }
    transitions
    {
        neg_bye: goto neg_bye on true;  
    }
    onexit 
    {
        neg_bye: do
        {
            set $feedback = #getMessageText();
            #log($feedback);
        }
    }
}

node neg_bye
{
    do
    {
        #sayText("Thank you for sharing. I will pass the feedback on upwards to management. We do look forward to seeing you at Acme Bread. Bye!");
        exit;
    }
}



// additional digressions 

digression new_seasonal
{
    conditions {on #messageHasIntent("new_seasonal");}
    do 
    {
        #sayText("We've got a new fall menu available. Some highlights are Vegetarian Autumn Squash Soup. Turkey Chili."); 
        #sayText(" Toasted Steak and Cheddar Sandwich. Grilled Mac and Cheese. Cinnamon Crunch Bagel. And Sausage and Pepperoni Flatbread Pizza."); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}

digression toasted_steak
{
    conditions {on #messageHasIntent("toasted_steak");}
    do 
    {
        #sayText("Grass fed beef, aged white cheddar, pickled red onions and horseradish sauce on Artisan Ciabatta. That's the Toasted Steak and White Cheddar Sandwich.", repeatMode: "ignore"); 

        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}

digression how_are_you
{
    conditions {on #messageHasIntent("how_are_you");}
    do 
    {
        #sayText("I'm well, thank you!", repeatMode: "ignore");
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Sorry we didn't see this through. Call back another time. Bye!");
        #disconnect();
        exit;
    }
}
