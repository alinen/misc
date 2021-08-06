import java.awt.*;
import java.awt.Robot.*;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.InputEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import javax.swing.*;
import static java.awt.GraphicsDevice.WindowTranslucency.*;
import java.util.ArrayList;
import java.util.Date;
 
public class MouseRecorder extends JFrame implements ActionListener,KeyListener {
    private JTextField _pidTextField = null;
    private boolean _show = true;

    private class MouseClick {
        public int x;
        public int y;
        public String type;
        public float time;
    }
    private ArrayList<MouseClick> _clicks = new ArrayList<MouseClick>();

    public MouseRecorder() throws AWTException {
        super("MouseRecorder");
 
        setBackground(new Color(0,0,0,0));
        setSize(new Dimension(300,200));
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setAlwaysOnTop(true);
        setOpacity(1.0f);
 
        JPanel panel = new JPanel() {
            @Override
            protected void paintComponent(Graphics g) {
                if (g instanceof Graphics2D) {
                    final int R = 240;
                    final int G = 240;
                    final int B = 240;
 
                    Paint p =
                        new GradientPaint(0.0f, 0.0f, new Color(R, G, B, 10),
                            0.0f, getHeight(), new Color(R, G, B, 10), true);
                    Graphics2D g2d = (Graphics2D)g;
                    g2d.setPaint(p);
                    g2d.fillRect(0, 0, getWidth(), getHeight());
                }
            }
        };
        panel.setFocusable(true);
        setContentPane(panel);
        setLayout(new GridBagLayout());

        JButton saveButton = new JButton("Save...");
        saveButton.addActionListener(this);

        _pidTextField = new JTextField("0");

        JMenuBar menuBar=new JMenuBar();  
        menuBar.add(saveButton);  
        menuBar.add(new JLabel("PID: "));
        menuBar.add(_pidTextField);
        setJMenuBar(menuBar);
        addKeyListener(this);

        Robot robot = new Robot();
        MouseAdapter adapter = new MouseAdapter() {
            @Override
            public void mouseReleased(final MouseEvent e) {
                //System.out.println("release! " + e);
                int b = e.getButton();

                PointerInfo inf = MouseInfo.getPointerInfo();
                Point p = inf.getLocation();
                int x = (int) p.getX();
                int y = (int) p.getY();

                Rectangle r = getBounds();
                MouseClick click = new MouseClick();
                click.x = x;
                click.y = y;
                click.time = System.currentTimeMillis() / 1000;
                if (x < r.width) click.type = "left";
                else click.type = "right";
                _clicks.add(click);

                setVisible(false);
                final int mod =
                    b == 1 ? InputEvent.BUTTON1_DOWN_MASK
                    : b == 2 ? InputEvent.BUTTON2_DOWN_MASK
                    : InputEvent.BUTTON3_DOWN_MASK;
                SwingUtilities.invokeLater(new Runnable() {
                    public void run() {
                        //System.out.println("clicking " + mod+ " "+x+" "+y);
                        robot.mouseMove(x, y);
                        robot.mousePress(mod);
                        robot.mouseRelease(mod);
                        setVisible(true);
                        toFront();
                        repaint();
                        requestFocus();
                    }
                });
            }
        };
        panel.addMouseListener(adapter);

        /*
        KeyAdapter keyAdapter = new KeyAdapter() {
            @Override
            public void keyReleased(final KeyEvent e) {
                System.out.println("release! " + e);

                setVisible(false);
                SwingUtilities.invokeLater(new Runnable() {
                    public void run() {
                        System.out.println("key " + e.getKeyCode());
                        robot.keyPress(e.getKeyCode());
                        robot.keyRelease(e.getKeyCode());
                        setVisible(true);
                        toFront();
                        repaint();
                        requestFocus();
                    }
                });
            }
        };
        panel.addKeyListener(keyAdapter);
        */
    }

    public void actionPerformed(ActionEvent e) {
        String pid = _pidTextField.getText(); 
        //System.out.println("Time to save! "+pid);

        try {
            String timeStamp = new java.text.SimpleDateFormat("yyyy.MM.dd.HH.mm.ss").format(new Date());
            String fileName = pid+"-"+timeStamp+"-clicks.csv";
            BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
            for (MouseClick click : _clicks) {
                String str = click.type+","+click.time+","+click.x+","+click.y+"\n";
                writer.write(str);
            }
            writer.close();
        }
        catch (IOException error) {
            System.out.println("Cannot write file.");
        }

    } 

    public void keyPressed(KeyEvent k) {}
    public void keyTyped(KeyEvent k) {}
    public void keyReleased(KeyEvent k) {
        if (k.getKeyCode() == KeyEvent.VK_SPACE && k.isControlDown()) {
            _show = !_show;
            if (_show) setOpacity(1.0f);
            else setOpacity(0.1f);
        }
    }

    public static void main(String[] args) {
        // Determine what the GraphicsDevice can support.
        GraphicsEnvironment ge = 
            GraphicsEnvironment.getLocalGraphicsEnvironment();
        GraphicsDevice gd = ge.getDefaultScreenDevice();
        boolean isPerPixelTranslucencySupported = 
            gd.isWindowTranslucencySupported(PERPIXEL_TRANSLUCENT);

        //If translucent windows aren't supported, exit.
        if (!isPerPixelTranslucencySupported) {
            System.out.println(
                "Per-pixel translucency is not supported");
                System.exit(0);
        }

        JFrame.setDefaultLookAndFeelDecorated(true);

        // Create the GUI on the event-dispatching thread
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                try {
                    MouseRecorder gtw = new MouseRecorder();
                    gtw.setVisible(true);
                } catch(AWTException e) {
                    System.out.println("Cannot create mouse click robot.");
                }
            }
        });

    }
}
