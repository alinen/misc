class slingshot
{
    constructor(bodyA,bodyB)
    {
        var options=
    {
        bodyA:bodyA,
        pointB:bodyB, 
        stiffness:0.04,
        lenght:9
    }
    this.sling1=loadImage("sprites/sling1.png")
    this.sling2=loadImage("sprites/sling2.png")
    this.sling3=loadImage("sprites/sling3.png")
   this. chain =  Matter.Constraint.create(options) 
   this.pointB=bodyB;
   World.add(world,this.chain)
    }
    fly()
    {
        
        this.chain.bodyA=null

    }
    display()
    {
        image(this.sling1,200,20)
        image(this.sling2,170,20)
        
        
        if(this.chain.bodyA!=null)
        {
        push()
        var pointA=this.chain.bodyA.position;
       // var pointB=this.poi
       strokeWeight(7)
       stroke(124, 11, 11)
       
       if (pointA.x<220)
    {
        

        line(pointA.x-25,pointA.y,this.pointB.x-10,this.pointB.y)
        line(pointA.x-25,pointA.y,this.pointB.x+20,this.pointB.y)
        
        image(this.sling3,pointA.x-25,pointA.y-15,15,30)
    }
    else 
    {
        line(pointA.x+25,pointA.y,this.pointB.x-10,this.pointB.y)
        line(pointA.x+25,pointA.y,this.pointB.x+20,this.pointB.y-10)
        
        image(this.sling3,pointA.x+25,pointA.y-15,15,30)

    }

    pop()

     }

    }
    attach(bodyA)
    {
        this.chain.bodyA=bodyA

    }

}
