//
//  CourseTableViewController.swift
//  cs130
//
//  Created by Runjia Li on 11/11/18.
//  Copyright © 2018 Ram Yadav. All rights reserved.
//

import UIKit
import FirebaseDatabase

/// This view controller contains a table of all courses available
class CourseTableViewController: UITableViewController {

    var ref: DatabaseReference?
    var courses = [Course]()
    var accountController: AccountController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up navigation bar attributes
        self.navigationController?.navigationBar.barTintColor = APP_BLUE
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "All Courses"
        
        // Connect to DB
        self.ref = Database.database().reference().child("majors")
        self.fetchCourses()
        
        // Register cells
        tableView.register(CourseTableViewCell.self, forCellReuseIdentifier: "courseCell")
    }

    /// Get a list of all available courses from the database
    func fetchCourses() {
        self.ref?.observe(.value) { (DataSnapshot) in
            var fetchedCourses = [Course]()
            for item in DataSnapshot.children {
                let major = item as! DataSnapshot
                for course in major.children {
                    let newCourse = Course(major: major.key , snapshot: course as! DataSnapshot)
                    fetchedCourses.append(newCourse)
                }
            }
            self.courses = fetchedCourses
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    // Display the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        let course = self.courses[indexPath.row]
        cell.setupContent(course: course)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // Pressing a cell redirects to the course info page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses[indexPath.row]
        let courseDetailViewController = CourseDetailViewController(course: course, accountController: self.accountController)
        self.navigationController?.pushViewController(courseDetailViewController, animated: true)
    }
}

/// This is a table cell that displays the course name, major, professor and quarter
class CourseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let id: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = label.font.withSize(14.0)
        return label
    }()
    
    private func setupViews() {
        self.addSubview(self.name)
        self.addSubview(self.id)
        // self.addSubview(self.enroll)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v" : self.name]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v" : self.id]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[v]-1-[v2]-15-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v" : self.name, "v2": self.id]))
    }
    
    /// Set up the content of the cell based on information of a course
    /// - parameters:
    ///     - course: A course of interest
    func setupContent(course: Course) {
        self.name.text = course.major + " " + course.id + ": " + course.title
        self.id.text = course.professor + ", " + course.quarter + " " + String(course.year)
    }
}
