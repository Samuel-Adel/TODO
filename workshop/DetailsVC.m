//
//  DetailsVC.m
//  workshop
//
//  Created by Samuel Adel on 17/04/2024.
//

#import "DetailsVC.h"
#import "Task.h"
@interface DetailsVC ()
@property (weak, nonatomic) IBOutlet UIImageView *taskStatusImage;
@property NSUserDefaults *defaults;
@property NSMutableArray<Task*> *tasks;
@property NSData*archivedTasks;
@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (weak, nonatomic) IBOutlet UIButton *addTaskBtn;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;
@property (weak, nonatomic) IBOutlet UITextView *descTxtField;

@end

@implementation DetailsVC
- (IBAction)changePriority:(id)sender {
    NSString *priority = [self priorityFromSegment:self.prioritySegment.selectedSegmentIndex];
       self.taskStatusImage.image = [self showCellImage:priority];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaults=[NSUserDefaults standardUserDefaults];
    if(self.task!=nil){
        [self setUpScreen ];
        self.statusSegment.hidden=false;
        self.statusText.hidden=false;
        self.taskStatusImage.hidden=false;
        self.taskStatusImage.image=  [self showCellImage:self.task.priority];

    }else{
        self.statusSegment.hidden=true;
        self.statusText.hidden=true;
        self.taskStatusImage.hidden=true;
    }
    // Do any additional setup after loading the view.
}
-(void) setUpScreen{
   self.nameTxtField.text=self.task.name;
    self.descTxtField.text=self.task.desc;
    self.datePicker.date=[self dateFromString:self.task.date];
    self.statusSegment.selectedSegmentIndex=[self segmentIndexFromStatus:self.task.status];
    self.prioritySegment.selectedSegmentIndex=[self segmentIndexFromPriority:self.task.priority ];
}
- (void)showAlertWithTitle:(NSString *)title firstMessage:(NSString *)firstMessage  completion:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
        message:[NSString stringWithFormat:@"%@\n", firstMessage]
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
        if ([title isEqualToString:@"Save"] && completionHandler) {
            completionHandler();
        }
    }];
    if ([title isEqualToString:@"Save"]) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                style:UIAlertActionStyleCancel
                handler:nil];
            [alert addAction:cancelAction];
        }
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)addTask:(id)sender {
    if (_nameTxtField.text.length == 0 || _descTxtField.text.length == 0) {
        [self showAlertWithTitle:@"Error" firstMessage:@"name and description can't be empty!!" completion:nil];
    } else{
        [self addValidUser];
    }
}
-(void)addValidUser{
    Task *newTask = [[Task alloc] init];
       newTask.name = self.nameTxtField.text;
       newTask.desc = self.descTxtField.text;
       newTask.date = [self formatDate:self.datePicker.date];
       newTask.status = [self statusFromSegment:self.statusSegment.selectedSegmentIndex];
       newTask.priority = [self priorityFromSegment:self.prioritySegment.selectedSegmentIndex];
    _tasks=[NSMutableArray new];
    _tasks=[self fetchSavedTasks];
    if(self.task!=nil){
        printf("task not equall null\n");
        for(int i=0;i<_tasks.count;i++){
            Task *currentTask = _tasks[i];
            if ([currentTask.name isEqualToString:self.task.name] && [currentTask.desc isEqualToString:self.task.desc]){
                [_tasks removeObjectAtIndex:i];
                    }
        }
    }
    [self showAlertWithTitle:@"Save" firstMessage:@"Are you sure you want to save this task?!" completion:^{
        [_tasks addObject:newTask];
        [self saveTasks];
        [self.navigationController popViewControllerAnimated:YES];
    }];
   
    
}
- (void) saveTasks{
    NSError*error;
    _archivedTasks=[NSKeyedArchiver archivedDataWithRootObject:_tasks requiringSecureCoding:YES error:&error];
    [_defaults setObject:_archivedTasks forKey:@"taskssKey"];
}
- (nonnull NSMutableArray *)fetchSavedTasks {
    NSData* savedTasks = [[NSUserDefaults standardUserDefaults] objectForKey:@"taskssKey"];
    
    NSMutableArray<Task *> *tasks;
    
    if (savedTasks == nil) {
        tasks = [NSMutableArray<Task *> array];
    } else {
        printf("data is here Details screen!!\n");
        NSData* savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"taskssKey"];
        NSSet* set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
        tasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:nil];
    }
    return tasks;
}
- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter stringFromDate:date];
}
- (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter dateFromString:string];
}


-(NSString *)statusFromSegment:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case 0:
            return @"Pending";
        case 1:
            return @"InProgress";
        case 2:
            return @"Completed";
        default:
            return @"Unknown";
    }
}
- (NSInteger)segmentIndexFromStatus:(NSString *)status {
    if ([status isEqualToString:@"Pending"]) {
        return 0;
    } else if ([status isEqualToString:@"InProgress"]) {
        return 1;
    } else if ([status isEqualToString:@"Completed"]) {
        return 2;
    } else {
        return -1;
    }
}


- (NSString *)priorityFromSegment:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case 2:
            return @"Low";
        case 1:
            return @"Medium";
        case 0:
            return @"High";
        default:
            return @"Unknown";
    }
}

- (NSInteger)segmentIndexFromPriority:(NSString *)priority {
    if ([priority isEqualToString:@"High"]) {
        return 0;
    } else if ([priority isEqualToString:@"Medium"]) {
        return 1;
    } else if ([priority isEqualToString:@"Low"]) {
        return 2;
    } else {
        return -1;
    }
}

- (UIImage *)showCellImage:(NSString *)priority {
    if ([priority isEqualToString:@"Low"]) {
        return [UIImage imageNamed:@"low"];
    } else if ([priority isEqualToString:@"Medium"]) {
        return [UIImage imageNamed:@"mid"];
    } else if ([priority isEqualToString:@"High"]) {
        return [UIImage imageNamed:@"high"];
    }
        return nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.navigationItem.rightBarButtonItems[1] setHidden:NO];
    [self.tabBarController.navigationItem.rightBarButtonItems[0] setHidden:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
