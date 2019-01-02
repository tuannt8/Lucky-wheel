/*
 * GL01Hello.cpp: Test OpenGL/GLUT C/C++ Setup
 * Tested under Eclipse CDT with MinGW/Cygwin and CodeBlocks with MinGW
 * To compile with -lfreeglut -lglu32 -lopengl32
 */

#include <GLUT/GLUT.h>  // GLUT, include glu.h and gl.h

#include "vector"
#include "string"
#include "math.h"

#include <iostream>

#import <Cocoa/Cocoa.h>


using namespace std;

#define PI 3.1415963

double r = 0.9;

int win_size_x = 1500;
int win_size_y = win_size_x / 3.5*2;

int vel_mode = 0; // normal
float vel_inc = 0;
float direct = 1;

int pos = 1;
float angle;

float pos_f = 1;
float vel = 1;
float max_vel = 2;
float min_vel = 0.5;
float acce = 0.002;

vector<vector<float>> color_code;
vector<int> sound_code;
vector<string> text_code;

////////////////////
vector<string> challengex2 = {
    "Blackjack vs trong tai, win x3",
    "Rut bai cao hon trong tai",
    "Ba cay voi doi ban",
    "Tien len vs ban, nhat thang",
    "Tien len vs ban, bet thua",
    "Tien len hai mo voi doi ban",
    "Poker voi doi ban",
    "Ba cay voi trong tai",
    "Blackjack thang doi ban 100",
    "Thua tuc khac",
    "Thang tuc khac",
    "Bo qua"
};
float dyy = 1.6/challengex2.size();
int cpos = 0;
float cvel=0;
float cacc = 0.001;
float cpos_f = cpos;


NSSound *clickSound = [[NSSound alloc] initWithContentsOfFile:@"click.m4a" byReference:NO];
vector<NSSound*> sound_array;

float da = (float)1./100. * PI * 2;

void renderBitmapString(float x,float y, char* text, void* font = GLUT_BITMAP_TIMES_ROMAN_24)
{
    char *c;
    int l=strlen( text );
    glRasterPos3f(x - 0.015*l, y,0);
    for (c=text; *c != '\0'; c++) {
        glutBitmapCharacter(font, *c);
    }
}

void draw_challange()
{
    glColor3f(0,0,1);
    glBegin(GL_QUADS);
    float yp = (float)cpos/challengex2.size() * 1.6 - 0.8 - dyy*0.5;
    glVertex2f(1.2, yp);
    glVertex2f(2.35, yp);
    glVertex2f(2.35, yp + dyy);
    glVertex2f(1.2, yp + dyy);
    glEnd();
    
    glColor3f(1, 1, 1);
    for (int i = 0; i < challengex2.size(); i++)
    {
        float yy = i*dyy - 0.8;
        renderBitmapString(1.7, yy, &challengex2[i][0]);
    }
}

void draw_vel_bar()
{
    if(vel > 0)
    {
    glBegin(GL_TRIANGLES);
    
//    glColor3f(1,1,1);
//    glVertex2f(1,0.4);
//    glVertex2f(1.1,0.4);
//    glVertex2f(1,-0.4);

    
    float l = vel/max_vel - 0.4;
    float ww = 0.1 *vel/max_vel + 1;
    glColor3f(vel/max_vel,0,0);
    glVertex2f(1,l);
    
    glVertex2f(ww,l);
    
    glColor3f(1,1,1);
    glVertex2f(1,-0.4);
    
//    glColor3f(0,0,1);
//    glVertex2f(1.1,-0.4);
    
    glEnd();
        
        renderBitmapString(1, -0.5, "Quay", GLUT_BITMAP_9_BY_15);
    }
}

void draw_fan(int index, float* color)
{
    float alpha = -angle + (float)index/100. * PI * 2;
    
    glBegin(GL_TRIANGLES);
    glColor3fv(color);
    glVertex2f(0,0);
    glVertex2f(r*cos(alpha), r*sin(alpha));
    glVertex2f(r*cos(alpha + da), r*sin(alpha + da));
    glEnd();
}


void draw_circle(float r, bool all = true)
{
    glBegin(GL_TRIANGLES);
    int dis = 100;
    float da_ = 2*PI/dis;
    for (int i = 0; i < dis; i++)
    {
        float alpha = (float)i/dis * PI * 2;
        glVertex2f(0,0);
        glVertex2f(r*cos(alpha), r*sin(alpha));
        glVertex2f(r*cos(alpha + da_), r*sin(alpha + da_));
    }
    glEnd();
    
    glColor3f(0.3,0.3,0.3);
    glBegin(GL_LINES);
    for (int i = all?0:1; i < dis; i++)
    {
        float alpha = (float)i/dis * PI * 2;
        glVertex2f(r*cos(alpha), r*sin(alpha));
        glVertex2f(r*cos(alpha + da_), r*sin(alpha + da_));
    }
    glEnd();
    
}

void draw_choice(int index, float* color)
{
    static float scale = 1.05;
    float alpha = -da*2;
    
    glBegin(GL_TRIANGLES);
//    glColor3fv(color);
    glColor3f(0.7, 0.7, 0.7);
    glVertex2f(0.66,0.66*sin(da/2));
    glVertex2f(0.4*scale*cos(alpha), 0.4*scale*sin(alpha));
    glVertex2f(0.4*scale*cos(alpha + da*5), 0.4*scale*sin(alpha + da*5));
    glEnd();
    
    glBegin(GL_LINE_LOOP);
    glColor3f(0,0,0);
    glVertex2f(0.66,0.66*sin(da/2));
    glVertex2f(0.4*scale*cos(alpha), 0.4*scale*sin(alpha));
    glVertex2f(0.4*scale*cos(alpha + da*5), 0.4*scale*sin(alpha + da*5));
    glEnd();
}


/* Handler for window-repaint event. Call back when the window first appears and
 whenever the window needs to be re-painted. */
void display() {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // Set background color to black and opaque
    glClear(GL_COLOR_BUFFER_BIT);         // Clear the color buffer (background)
    
    
    static bool workArounded = false;
    if (!workArounded)
    {
        workArounded = true;
        glutReshapeWindow(win_size_x+1, win_size_y);
    }
    
    glColor3f(1,1,1);
    draw_challange();
    
    draw_vel_bar();
    
    // Draw a Red 1x1 Square centered at origin
    angle = (float)pos/100. * PI * 2;
    for (int i = 0; i < 100; i++)
    {
        draw_fan(i, &color_code[i][0]);
    }
    
    draw_choice(pos, &color_code[pos][0]);
    
    
//    glColor3fv(&color_code[pos][0]);
    glColor3f(0.7, 0.7, 0.7);
    draw_circle(0.6,false);
    
    glColor3f(1, 1, 1);
    draw_circle(0.55);
    
    
    glColor3f(0.6, 0.6, 0.6);
    glPushMatrix();
    glTranslatef(0, 0.13, 0);
    draw_circle(0.1);
    
    glPopMatrix();
    glColor3fv(&color_code[pos][0]);
    auto st = std::to_string(pos);
    renderBitmapString(0,0.1, &st[0]);
    
    glColor3f(0,0,0);
    renderBitmapString(0,-0.1, &text_code[pos][0]);
    
//    glRotatef(-angle, 0, 0, 1);
    glColor3f(0.5, 0, 0);
    for (int i = 5; i < 100; i+= 10)
    {
        float aa = -angle + (float)i/100. * PI * 2;
        renderBitmapString(0.7*cos(aa),0.7*sin(aa), &text_code[i][0], GLUT_BITMAP_9_BY_15);
    }
    
    
    if(vel > 0)
    {
        pos_f += vel;
        

        
        if(pos_f >= 100)
            pos_f = 0;
        
        if(text_code[(int)pos_f].compare(text_code[pos]) != 0)
            //        if((int)pos_f > pos)
        {
            clickSound.volume = 0.1;
            [clickSound play];
            //            [NSThread sleepForTimeInterval:0.1f];
        }
        
        pos = (int)pos_f;
        vel -= acce;
        
        if(vel <= 0)
        {
            vel = 0;
            // Play sound
            [sound_array[sound_code[pos]] play];
//            [winSound play];
        }
    }
    
    if(vel_mode==1)
    {
        vel += vel_inc;
        vel_inc += direct*0.0005;
        if(vel > max_vel)
        {
            vel = max_vel;
            vel_inc = -vel_inc;
            direct = -1;
        }
        
        if(vel < min_vel)
        {
            vel = min_vel;
            vel_inc = -vel_inc;
            direct = 1;
        }
    }
    
    if (cvel > 0)
    {
        cpos_f += cvel;
        if (cpos_f >= challengex2.size())
        {
            cpos_f = 0;
        }
        if((int)cpos_f != cpos)
        {
             clickSound.volume = 0.1;
           [clickSound play];
        }
        
        cpos = (int)cpos_f;
        
        cvel -= cacc;
        if (cvel <= 0)
        {
            cvel = 0;
            [sound_array[1] play];
        }
    }
    
    glFinish();
    glutSwapBuffers();                          // swap buffers
    
}

void init()
{
    vector<vector<float>> cc = {
        {0.7,0.7,1},
        {0.5,0.5,0.5},
        {0.7,0.8,1},
        {0.5,0.5,1},
        {0.5,1,0.5},
        {0.6,0.6,1},
        {1,0.8,0.6},
        {0.4,1,0.7},
        {0.7,1,0.6},
        {1,0.5,0.5}
    };
    
    vector<string> tt = {
        "+ 300", "Phao tay", "x2", "x5", "x10", "x3", "-100", "Cuop x5", "Cuop tat/10", "Bi cuop tat/10"
    };
    vector<int> ssound = {1,1,1,1,1,1,0,1,1,0};
    
    color_code.resize(100);
    text_code.resize(100);
    // sound
    sound_code.resize(100);
    for (int i = 0; i < 100; i++)
    {
        int ii = i/10;
        color_code[i] = cc[ii];
        text_code[i] = tt[ii];
        sound_code[i] = ssound[ii];
    }
    
    NSSound *winSound = [[NSSound alloc] initWithContentsOfFile:@"win.mp3" byReference:NO];
    NSSound *lose1Sound = [[NSSound alloc] initWithContentsOfFile:@"lose1.mp3" byReference:NO];
    NSSound *evilSound = [[NSSound alloc] initWithContentsOfFile:@"evil.mov" byReference:NO];
    NSSound *heavenSound = [[NSSound alloc] initWithContentsOfFile:@"heaven.mp3" byReference:NO];
    sound_array.push_back(lose1Sound); // lose normal
    sound_array.push_back(winSound); // win normal
    sound_array.push_back(evilSound); // Hard lose
    sound_array.push_back(heavenSound); //hard win
    
    
    // Special
    vector<int> mat_tat = {13,49,53,4, 44,78};
    for (int ii : mat_tat)
    {
        color_code[ii] = {1, 0, 0};
        text_code[ii] = "Bi cuop tat";
        sound_code[ii] = 2;
    }
    
    vector<int> cuop_tat = {10,50,60, 70, 80,90};
    for (int ii : cuop_tat)
    {
        color_code[ii] = {0, 1, 0};
        text_code[ii] = "Cuop tat";
        sound_code[ii] = 3;
    }
    
    vector<int> doi_nguoi = {16,26,36,56,56,66};
    for (int ii : doi_nguoi)
    {
        color_code[ii] = {1, 0, 1};
        text_code[ii] = "Doi nguoi";
        sound_code[ii] = 2;
    }
}

void keyboard(unsigned char k, int,int)
{
    if(k==' ' && vel_mode==0)
    {
        vel = rand()/RAND_MAX * 0.5;
        vel_mode = 1;
        vel_inc = 0.01;
        direct = 1;
    }
    
    if (k == '\r')
    {
        cvel = rand()/RAND_MAX + 0.5;
    }
}

void keyUp(unsigned char k, int,int)
{
    if(k==' ' && vel_mode==1)
    {
        vel_mode = 0;
    }
    
    
}

void glutTimer(int)
{
    glutPostRedisplay();
    glutTimerFunc(10, glutTimer, 0);
}

void reshape(int size_x, int size_y)
{
    // circle: (-1,-1) : (1,1)
    // bar: 0.3
    // x2: 0.5
    float ratio = 3.5/2.0;
    
    int ox,oy,sx,sy;
    if((float)size_x/size_y > ratio)
    {
        oy = 0;
        sy = size_y;
        sx = sy * ratio;
        ox = (size_x - sx)*0.5;
    }else{
        ox = 0;
        sx = size_x;
        sy = sx / ratio;
        oy = (size_y - sy)*0.5;
    }
    
     glViewport(ox, oy, sx, sy);
    
    glMatrixMode(GL_PROJECTION);                // update projection
    glLoadIdentity();
    gluOrtho2D(-1, 2.5, -1, 1);
    
    glMatrixMode(GL_MODELVIEW);     // Select The Modelview Matrix
    glLoadIdentity();
    
   
//    glViewport(0,0,size_x,size_y);
    
    glutPostRedisplay();
}

/* Main function: GLUT runs as a console application starting at main()  */
int main(int argc, char** argv) {
    init();
    

    
    
    
    glutInit(&argc, argv);                 // Initialize GLUT
    glutCreateWindow("OpenGL Setup Test"); // Create a window with the given title
    glutInitWindowSize(win_size_x, win_size_y);   // Set the window's initial width & height
    glutInitWindowPosition(50, 50); // Position the window's initial top-left corner
    
    glEnable(GL_MULTISAMPLE);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH | GLUT_MULTISAMPLE);
    
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glEnable(GL_POINT_SMOOTH);
    glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glutDisplayFunc(display); // Register display callback handler for window re-paint
    glutReshapeFunc(reshape);
    glutKeyboardFunc(keyboard);
    glutTimerFunc(10, glutTimer, 0);
    glutKeyboardUpFunc(keyUp);

    
    glutMainLoop();           // Enter the event-processing loop
    return 0;
}
