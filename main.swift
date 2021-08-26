//
//  main.swift
//  OperationQueue
//
//  Created by  g01dt00th on 26.08.2021.
//

import Foundation


class AsyncOperation: Operation {
    
    public enum State: String {
        case ready, executing, finished
        
        var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet{
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}



extension AsyncOperation {
    override var isAsynchronous: Bool {
        true
    }

    override open var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
    
    override open func cancel() {
        super.cancel()
        state = .finished
    }
}


class MyOperation: AsyncOperation {

    private var block: (() -> ())?
    
    func addBlock(_ block: @escaping () -> Void ) {
        self.block = block
    }

    override func main() {
        block?()
    }

}


final class MyClass {

    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 3
        return queue
    }()

    func run() {
        let op1 = MyOperation()
        op1.addBlock { [unowned op1] in
            
            
            DispatchQueue.global().async {
                sleep(1)
                print("op1 finished")
                op1.state = .finished
            }
        }
        op1.name = "op1"

        let op2 = MyOperation()
        op2.addBlock { [unowned op2] in
            
            
            DispatchQueue.global().async {
                sleep(1)
                print("op2 finished")
                op2.state = .finished
            }
        }
        op2.name = "op2"
        
        let op3 = MyOperation()
        op3.addBlock { [unowned op3] in
            
            
            DispatchQueue.global().async {
                sleep(1)
                print("op3 finished")
                op3.state = .finished
            }
        }
        op3.name = "op3"

        op3.addDependency(op2)
        op2.addDependency(op1)

        queue.addOperations([op3, op1, op2], waitUntilFinished: true)

        print("queue finished")
    }

}

let test = MyClass()
test.run()
print("stop")
